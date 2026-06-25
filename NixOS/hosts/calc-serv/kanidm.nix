{
  config,
  pkgs,
  ...
}:
let
  domain = "id.sandi05.com";
  cert = config.security.acme.certs.${domain};
in
{
  sops.secrets.sandi05-cloudflare-acme = {
    format = "yaml";
    sopsFile = ../../secrets/cloudflare-sandi05-acme.enc.yaml;
    mode = "0400";
    owner = "acme";
    group = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nobuta05@gmail.com";
    certs.${domain} = {
      inherit domain;
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.sandi05-cloudflare-acme.path;
      dnsPropagationCheck = true;
      group = "kanidm";
    };
  };

  # kanidm
  sops.secrets.kanidm-idm-admin = {
    format = "binary";
    sopsFile = ./secrets/kanidm-idm-admin.enc;
    mode = "0400";
    owner = "kanidm";
    group = "kanidm";
  };

  sops.secrets.kanidm-mail-sender = {
    format = "binary";
    sopsFile = ./secrets/kanidm-mail-sender.enc.toml;
    mode = "0440";
    owner = "root";
    group = "kanidm";
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_10;
    client = {
      enable = true;
      settings.uri = "https://${domain}";
    };

    server = {
      enable = true;
      settings = {
        bindaddress = "127.0.0.1:8443";
        ldapbindaddress = null;
        origin = "https://${domain}";
        domain = domain;
        tls_chain = "${cert.directory}/fullchain.pem";
        tls_key = "${cert.directory}/key.pem";
      };
    };

    provision = {
      enable = true;
      instanceUrl = "https://${domain}";
      idmAdminPasswordFile = config.sops.secrets.kanidm-idm-admin.path;
      extraJsonFile = ./kanidm-provision.json;
      groups = {
        server-users = {
          overwriteMembers = false;
        };
        idm_people_self_mail_write = {
          members = [ "server-users" ];
          overwriteMembers = false;
        };
      };
    };

    unix = {
      enable = true;
      sshIntegration = true;
      settings = {
        hsm_type = "tpm_if_possible";
        kanidm.pam_allowed_login_groups = [ "server-users" ];
        home_prefix = "/users/";
        home_mount_prefix = "/users";
        home_attr = "uuid";
        home_alias = "name";
        uid_attr_map = "name";
        gid_attr_map = "name";
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/" = {
        proxyPass = "https://127.0.0.1:8443";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_name ${domain};
          proxy_ssl_server_name on;
          proxy_set_header Host ${domain};
          proxy_set_header X-Forwarded-Proto https;
        '';
      };
    };
  };

  users.users.nginx.extraGroups = [ "kanidm" ];

  systemd.services.kanidm = {
    after = [ "acme-${domain}.service" ];
    requires = [ "acme-${domain}.service" ];
  };

  systemd.services.kanidm-mail-sender = {
    description = "Kanidm mail sender";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "kanidm.service"
    ];
    requires = [ "kanidm.service" ];

    serviceConfig = {
      ExecStart = "${config.services.kanidm.package}/bin/kanidm-mail-sender -c /etc/kanidm/config -m ${config.sops.secrets.kanidm-mail-sender.path}";
      User = "kanidm";
      Group = "kanidm";
      Restart = "on-failure";
      RestartSec = "10s";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };
  };

  systemd.services.kanidm-unixd-tasks.serviceConfig.BindPaths = [ "/users" ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
