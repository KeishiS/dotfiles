{
  config,
  lib,
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

  sops.secrets.kanidm-idm-admin = {
    format = "binary";
    sopsFile = ./secrets/kanidm-idm-admin.enc;
    mode = "0400";
    owner = "kanidm";
    group = "kanidm";
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

  services.kanidm = {
    package = lib.mkForce pkgs.kanidm_1_9.withSecretProvisioning;
    enableServer = true;
    serverSettings = {
      bindaddress = "127.0.0.1:8443";
      ldapbindaddress = null;
      origin = "https://${domain}";
      domain = domain;
      tls_chain = "${cert.directory}/fullchain.pem";
      tls_key = "${cert.directory}/key.pem";
    };

    provision = {
      enable = true;
      instanceUrl = "https://${domain}";
      idmAdminPasswordFile = config.sops.secrets.kanidm-idm-admin.path;

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
  };

  services.nginx.virtualHosts.${domain} = {
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

  users.users.nginx.extraGroups = [ "kanidm" ];

  systemd.services.kanidm = {
    after = [ "acme-${domain}.service" ];
    requires = [ "acme-${domain}.service" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
