{
  config,
  lib,
  pkgs,
  ...
}:
let
  agentServicesConsumers = import ../../home/agent/agent-services-consumers.nix;
  enabledAgentServicesConsumers = lib.filterAttrs (
    _: consumer: consumer.enabled
  ) agentServicesConsumers;
  leantimeUid = 955;
  leantimeGid = 955;
  toolhiveUid = 956;
  toolhiveGid = 956;
  toolhiveStateDir = "/var/lib/toolhive";
  toolhiveRuntimeDir = "/run/toolhive";
  toolhiveUserRuntimeDir = "/run/user/${toString toolhiveUid}";
  toolhiveEnvironment = [
    "HOME=${toolhiveStateDir}"
    "XDG_RUNTIME_DIR=${toolhiveRuntimeDir}"
    "XDG_CONFIG_HOME=${toolhiveStateDir}/runtime-config"
    "XDG_DATA_HOME=${toolhiveStateDir}/data"
    "XDG_STATE_HOME=${toolhiveStateDir}/state"
    "XDG_CACHE_HOME=/var/cache/toolhive"
    "TMPDIR=/var/cache/toolhive/tmp"
    "TOOLHIVE_PODMAN_SOCKET=${toolhiveRuntimeDir}/podman.sock"
    "TOOLHIVE_SKIP_UPDATE_CHECK=true"
  ];
  yamlFormat = pkgs.formats.yaml { };
  toolhiveVmcpConfigs = lib.mapAttrs (
    name: consumer:
    yamlFormat.generate "agent-services-${name}-vmcp.yaml" (
      import ../../modules/services/agent-services/vmcp-config.nix {
        inherit consumer;
      }
    )
  ) enabledAgentServicesConsumers;
  toolhiveVmcpUnitNames = lib.mapAttrsToList (
    name: _: "toolhive-vmcp-${name}.service"
  ) enabledAgentServicesConsumers;
  triliumnextPermissionProfile = ./toolhive/triliumnext-permission-profile.json;
  leantimePermissionProfile = ./toolhive/leantime-permission-profile.json;
  triliumnextMcpUpstreamImage = "ghcr.io/tan-yong-sheng/triliumnext-mcp@sha256:061f5bd7030b11f0165f0bdcd22de29ed069ad44ee52162ee19d78c2c7f03803";
  triliumnextMcpLocalImage = "localhost/triliumnext-mcp:0.3.17";
  leantimeMcp = pkgs.callPackage ./toolhive/leantime-mcp.nix { };
  leantimeMcpImage = pkgs.dockerTools.buildLayeredImage {
    name = "localhost/leantime-mcp";
    tag = "1.6.5";
    contents = [
      leantimeMcp
      pkgs.cacert
    ];
    config = {
      Entrypoint = [ "${leantimeMcp}/bin/leantime-mcp" ];
      User = "65532:65532";
      WorkingDir = "/tmp";
      Env = [
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
    };
  };
  waitForToolhivePodman = ''
    podman_ready=
    for attempt in $(${pkgs.coreutils}/bin/seq 1 30); do
      if ${config.virtualisation.podman.package}/bin/podman \
        --remote \
        --url unix://${toolhiveRuntimeDir}/podman.sock \
        info >/dev/null 2>&1; then
        podman_ready=1
        break
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done
    if [ -z "$podman_ready" ]; then
      echo "ToolHive Podman API did not become ready" >&2
      exit 1
    fi
  '';
  toolhiveServiceHardening = {
    User = "toolhive";
    Group = "toolhive";
    Environment = toolhiveEnvironment;
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectHome = true;
    ProtectSystem = "strict";
    ReadWritePaths = [
      toolhiveStateDir
      "/var/cache/toolhive"
      toolhiveRuntimeDir
    ];
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
  };
  toolhiveVmcpServices = lib.mapAttrs' (
    name: consumer:
    lib.nameValuePair "toolhive-vmcp-${name}" {
      description = "OIDC-protected ToolHive virtual MCP endpoint for ${name}";
      wantedBy = [ "multi-user.target" ];
      after = [
        "toolhive-triliumnext.service"
        "toolhive-leantime.service"
      ];
      wants = [
        "toolhive-triliumnext.service"
        "toolhive-leantime.service"
      ];
      unitConfig.ConditionPathExists = [
        config.sops.secrets.triliumnext-etapi-token.path
        config.sops.secrets.toolhive-vmcp-session-hmac-secret.path
      ];
      serviceConfig = toolhiveServiceHardening // {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        LoadCredential = "vmcp-session-hmac-secret:${config.sops.secrets.toolhive-vmcp-session-hmac-secret.path}";
      };
      script = ''
        VMCP_SESSION_HMAC_SECRET="$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/vmcp-session-hmac-secret")"
        export VMCP_SESSION_HMAC_SECRET
        exec ${pkgs.toolhive}/bin/thv vmcp serve \
          --config ${toolhiveVmcpConfigs.${name}} \
          --host 127.0.0.1 \
          --port ${toString consumer.port} \
          --enable-audit
      '';
    }
  ) enabledAgentServicesConsumers;
  toolhiveVmcpLocations = lib.listToAttrs (
    lib.concatMap (consumer: [
      {
        name = "= ${consumer.basePath}/mcp";
        value = {
          proxyPass = "http://127.0.0.1:${toString consumer.port}/mcp";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
          '';
        };
      }
      {
        name = "= /.well-known/oauth-protected-resource${consumer.basePath}/mcp";
        value.proxyPass = "http://127.0.0.1:${toString consumer.port}/.well-known/oauth-protected-resource/mcp";
      }
    ]) (lib.attrValues enabledAgentServicesConsumers)
  );
in
{
  imports = [ { systemd.services = toolhiveVmcpServices; } ];

  sops.secrets.leantime-env = {
    format = "dotenv";
    sopsFile = ./secrets/leantime.env.enc;
    owner = "leantime";
    group = "leantime";
    mode = "0400";
  };

  sops.secrets.triliumnext-etapi-token = {
    format = "binary";
    sopsFile = ./secrets/triliumnext-etapi-token.enc;
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [
      "toolhive-triliumnext.service"
    ]
    ++ toolhiveVmcpUnitNames;
  };

  sops.secrets.toolhive-vmcp-session-hmac-secret = {
    format = "binary";
    sopsFile = ./secrets/toolhive-vmcp-session-hmac-secret.enc;
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = toolhiveVmcpUnitNames;
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

  users.groups.toolhive.gid = toolhiveGid;
  users.users.toolhive = {
    isSystemUser = true;
    uid = toolhiveUid;
    group = "toolhive";
    home = "/var/lib/toolhive";
    createHome = true;
    linger = true;
    subUidRanges = [
      {
        startUid = 265536;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 265536;
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
      "mcp.sandi05.com".locations = toolhiveVmcpLocations // {
        "/".return = "404";
      };
    };
  };

  # ToolHive owns its rootless Podman API. Neither this socket nor the
  # ToolHive state directory is shared with calc-serv or agent-sandbox.
  virtualisation.podman.enable = true;
  environment.systemPackages = [ pkgs.toolhive ];
  systemd.tmpfiles.rules = [
    # Keep the API socket path stable across service restarts. Unlike
    # RuntimeDirectory=, tmpfiles does not remove it while dependent units
    # are being restarted in the same transaction.
    "d ${toolhiveRuntimeDir} 0700 toolhive toolhive -"
    "d ${toolhiveStateDir}/credentials 0750 root toolhive -"
    # Policy files are writable only by root. The ToolHive account can read
    # them but cannot replace an allowlist after a connector compromise.
    "d ${toolhiveStateDir}/config 0750 root toolhive -"
    # Keep ToolHive's mutable runtime configuration separate from the
    # root-owned policy files above.
    "d ${toolhiveStateDir}/runtime-config 0700 toolhive toolhive -"
    "d ${toolhiveStateDir}/data 0700 toolhive toolhive -"
    "d ${toolhiveStateDir}/state 0700 toolhive toolhive -"
    "d /var/cache/toolhive 0700 toolhive toolhive -"
    "d /var/cache/toolhive/tmp 0700 toolhive toolhive -"
  ];
  systemd.services.toolhive-podman = {
    description = "Rootless Podman API for ToolHive";
    wantedBy = [ "multi-user.target" ];
    after = [
      "local-fs.target"
      "user@${toString toolhiveUid}.service"
    ];
    requires = [ "user@${toString toolhiveUid}.service" ];
    path = [ config.virtualisation.podman.package ];
    serviceConfig = {
      Type = "simple";
      User = "toolhive";
      Group = "toolhive";
      StateDirectory = "toolhive";
      StateDirectoryMode = "0700";
      CacheDirectory = "toolhive";
      CacheDirectoryMode = "0700";
      Environment = toolhiveEnvironment ++ [
        "XDG_RUNTIME_DIR=${toolhiveUserRuntimeDir}"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=${toolhiveUserRuntimeDir}/bus"
      ];
      ExecStart = "${config.virtualisation.podman.package}/bin/podman system service --time=0 unix:///run/toolhive/podman.sock";
      Restart = "on-failure";
      RestartSec = "5s";
      # Rootless Podman needs the newuidmap/newgidmap capability wrappers to
      # enter the subordinate UID/GID ranges assigned above.
      NoNewPrivileges = false;
      # ProtectHome also masks /run/user, which rootless Podman, netavark and
      # the user bus require. Normal ownership and mode 0700 on user runtime
      # directories still prevent access to other users' runtime state.
      ProtectHome = false;
      ProtectSystem = "strict";
      ReadWritePaths = [
        "/var/lib/toolhive"
        "/var/cache/toolhive"
        "/run/toolhive"
        toolhiveUserRuntimeDir
      ];
    };
  };

  systemd.services.toolhive-group = {
    description = "Provision the ToolHive agent-services group";
    wantedBy = [ "multi-user.target" ];
    after = [ "toolhive-podman.service" ];
    requires = [ "toolhive-podman.service" ];
    path = [
      pkgs.gnugrep
      pkgs.toolhive
      config.virtualisation.podman.package
    ];
    serviceConfig = toolhiveServiceHardening // {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      ${waitForToolhivePodman}
      if ! thv group create agent-services; then
        thv group list | grep -Fq agent-services
      fi
    '';
  };

  systemd.services.toolhive-triliumnext = {
    description = "TriliumNext MCP connector managed by ToolHive";
    wantedBy = [ "multi-user.target" ];
    after = [
      "toolhive-group.service"
      "toolhive-triliumnext-image.service"
    ];
    requires = [
      "toolhive-group.service"
      "toolhive-triliumnext-image.service"
    ];
    unitConfig.ConditionPathExists = config.sops.secrets.triliumnext-etapi-token.path;
    serviceConfig = toolhiveServiceHardening // {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "5s";
      LoadCredential = "triliumnext-token:${config.sops.secrets.triliumnext-etapi-token.path}";
    };
    script = ''
      set -eu
      export TOOLHIVE_SECRETS_PROVIDER=environment
      TOOLHIVE_SECRET_TRILIUM_ETAPI_TOKEN="$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/triliumnext-token")"
      export TOOLHIVE_SECRET_TRILIUM_ETAPI_TOKEN
      # The connector exposes all write implementations as one permission
      # class. vMCP Cedar policy is the enforcement boundary that permits
      # creation, updates and attribute management but still denies delete.
      exec ${pkgs.toolhive}/bin/thv run \
        --foreground \
        --name triliumnext \
        --group agent-services \
        --transport stdio \
        --permission-profile ${triliumnextPermissionProfile} \
        --secret TRILIUM_ETAPI_TOKEN,target=TRILIUM_API_TOKEN \
        --env TRILIUM_API_URL=https://notes.sandi05.com/etapi \
        --env 'PERMISSIONS=READ;WRITE' \
        --enable-audit \
        ${triliumnextMcpLocalImage}
    '';
  };

  systemd.services.toolhive-triliumnext-image = {
    description = "Pull the pinned TriliumNext MCP image into rootless Podman";
    wantedBy = [ "multi-user.target" ];
    after = [ "toolhive-podman.service" ];
    requires = [ "toolhive-podman.service" ];
    path = [ config.virtualisation.podman.package ];
    serviceConfig = toolhiveServiceHardening // {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      ${waitForToolhivePodman}
      image_id="$(podman \
        --remote \
        --url unix://${toolhiveRuntimeDir}/podman.sock \
        pull \
        --quiet \
        ${triliumnextMcpUpstreamImage})"
      podman \
        --remote \
        --url unix://${toolhiveRuntimeDir}/podman.sock \
        tag \
        "$image_id" \
        ${triliumnextMcpLocalImage}
    '';
  };

  systemd.services.toolhive-leantime-image = {
    description = "Load the pinned Leantime MCP bridge image into rootless Podman";
    wantedBy = [ "multi-user.target" ];
    after = [ "toolhive-podman.service" ];
    requires = [ "toolhive-podman.service" ];
    path = [ config.virtualisation.podman.package ];
    serviceConfig = toolhiveServiceHardening // {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      ${waitForToolhivePodman}
      podman \
        --remote \
        --url unix://${toolhiveRuntimeDir}/podman.sock \
        load \
        --input ${leantimeMcpImage}
    '';
  };

  systemd.services.toolhive-leantime = {
    description = "Leantime MCP connector managed by ToolHive";
    wantedBy = [ "multi-user.target" ];
    after = [
      "toolhive-group.service"
      "toolhive-leantime-image.service"
    ];
    requires = [
      "toolhive-group.service"
      "toolhive-leantime-image.service"
    ];
    unitConfig = {
      ConditionPathExists = [
        "${toolhiveStateDir}/credentials/leantime-api-token"
        "${toolhiveStateDir}/config/leantime-read-tools"
      ];
      ConditionFileNotEmpty = "${toolhiveStateDir}/config/leantime-read-tools";
    };
    serviceConfig = toolhiveServiceHardening // {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "5s";
      LoadCredential = "leantime-token:${toolhiveStateDir}/credentials/leantime-api-token";
    };
    script = ''
      set -eu
      tools="$(${pkgs.coreutils}/bin/tr '\n' ',' < ${toolhiveStateDir}/config/leantime-read-tools)"
      tools="''${tools%,}"
      if [ -z "$tools" ]; then
        echo "the Leantime tool allowlist is empty" >&2
        exit 1
      fi

      export TOOLHIVE_SECRETS_PROVIDER=environment
      TOOLHIVE_SECRET_LEANTIME_API_TOKEN="$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/leantime-token")"
      export TOOLHIVE_SECRET_LEANTIME_API_TOKEN
      exec ${pkgs.toolhive}/bin/thv run \
        --foreground \
        --name leantime \
        --group agent-services \
        --transport stdio \
        --permission-profile ${leantimePermissionProfile} \
        --secret LEANTIME_API_TOKEN,target=LEANTIME_API_TOKEN \
        --tools "$tools" \
        --enable-audit \
        localhost/leantime-mcp:1.6.5 \
        https://project.sandi05.com/mcp \
        --auth-method Bearer \
        --max-retries 5 \
        --retry-delay 2000
    '';
  };

  # Only the lenovo nginx entry point is reachable from the LAN. Application
  # ports and the ToolHive management socket remain loopback/local.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp -s 192.168.100.31 --dport 80 -j nixos-fw-accept
  '';
}
