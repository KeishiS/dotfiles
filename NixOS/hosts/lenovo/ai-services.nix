{
  config,
  lib,
  pkgs,
  ...
}:
let
  leantimeUid = 955;
  leantimeGid = 955;
in
{
  sops.secrets.leantime-env = {
    format = "dotenv";
    sopsFile = ./secrets/leantime.env.enc;
    owner = "leantime";
    group = "leantime";
    mode = "0400";
  };

  users.groups.leantime.gid = leantimeGid;
  users.users.leantime = {
    isSystemUser = true;
    uid = leantimeUid;
    group = "leantime";
    home = "/var/lib/leantime";
    createHome = true;
    linger = true;
    subUidRanges = [
      {
        startUid = 200000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 200000;
        count = 65536;
      }
    ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "leantime" ];
    settings.mysqld = {
      bind-address = "127.0.0.1";
      innodb_buffer_pool_size = "256M";
    };
  };

  # services.mysql.ensureUsers uses unix_socket authentication. Leantime runs
  # in a container, so create its TCP/password account separately and
  # idempotently without putting the password in the Nix store or argv.
  systemd.services.leantime-database-user = {
    description = "Provision the Leantime MariaDB account";
    after = [
      "mysql.service"
      "sops-nix.service"
    ];
    requires = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      config.services.mysql.package
      pkgs.gnugrep
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
    script = ''
      set -eu
      set -a
      . ${lib.escapeShellArg config.sops.secrets.leantime-env.path}
      set +a

      if ! printf '%s' "$LEAN_DB_PASSWORD" | grep -Eq '^[0-9a-fA-F]+$'; then
        echo "LEAN_DB_PASSWORD must be a non-empty hexadecimal string" >&2
        exit 1
      fi

      ${config.services.mysql.package}/bin/mysql --protocol=socket <<SQL
      CREATE USER IF NOT EXISTS 'leantime'@'localhost' IDENTIFIED BY '$LEAN_DB_PASSWORD';
      ALTER USER 'leantime'@'localhost' IDENTIFIED BY '$LEAN_DB_PASSWORD';
      GRANT ALL PRIVILEGES ON leantime.* TO 'leantime'@'localhost';
      FLUSH PRIVILEGES;
      SQL
    '';
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.leantime = {
      image = "docker.io/leantime/leantime@sha256:617eba299b15c6dd68a05a2efaf834bc7731b09712eea8ea9402a075e63b48bd";
      pull = "missing";
      podman = {
        user = "leantime";
        sdnotify = "healthy";
      };
      environment = {
        LEAN_APP_URL = "https://project.sandi05.com";
        LEAN_DB_HOST = "127.0.0.1";
        LEAN_DB_PORT = "3306";
        LEAN_DB_USER = "leantime";
        LEAN_DB_DATABASE = "leantime";
        LEAN_SESSION_SECURE = "true";
        LEAN_OIDC_ENABLE = "true";
        LEAN_OIDC_PROVIDER_URL = "https://id.sandi05.com/oauth2/openid/leantime/";
        LEAN_OIDC_CLIENT_ID = "leantime";
      };
      environmentFiles = [ config.sops.secrets.leantime-env.path ];
      networks = [ "host" ];
      volumes = [
        "leantime-public-userfiles:/var/www/html/public/userfiles"
        "leantime-userfiles:/var/www/html/userfiles"
        "leantime-plugins:/var/www/html/app/Plugins"
        "leantime-logs:/var/www/html/storage/logs"
      ];
      capabilities = {
        ALL = false;
      };
      extraOptions = [
        "--health-cmd=curl -fsS http://127.0.0.1:8080/ || exit 1"
        "--health-interval=30s"
        "--health-retries=5"
        "--health-start-period=60s"
        "--tmpfs=/tmp:rw,nosuid,nodev,noexec"
        "--security-opt=no-new-privileges"
      ];
    };
  };

  systemd.services.podman-leantime = {
    after = [ "leantime-database-user.service" ];
    requires = [ "leantime-database-user.service" ];
  };

  services.trilium-server = {
    enable = true;
    dataDir = "/var/lib/trilium";
    host = "127.0.0.1";
    port = 8081;
    noAuthentication = false;
    noBackup = true;
    nginx = {
      enable = true;
      hostName = "notes.sandi05.com";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "project.sandi05.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 256M;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
          '';
        };
      };
      "notes.sandi05.com".extraConfig = ''
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
      '';
    };
  };

  virtualisation.podman.enable = true;

  # Only the lenovo nginx entry point is reachable from the LAN.
  # Application ports remain loopback/local.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp -s 192.168.100.31 --dport 80 -j nixos-fw-accept
  '';
}
