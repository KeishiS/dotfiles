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

  services.kanidm = {
    package = pkgs.kanidm_1_9;
    enableServer = true;
    enableClient = true;
    enablePam = true;
    serverSettings = {
      bindaddress = "127.0.0.1:8443";
      ldapbindaddress = null;
      origin = "https://${domain}";
      domain = domain;
      tls_chain = "${cert.directory}/fullchain.pem";
      tls_key = "${cert.directory}/key.pem";
    };
    clientSettings = {
      uri = "https://${domain}";
    };
    unixSettings = {
      pam_allowed_login_groups = [ "server-users" ];
      home_prefix = "/users/";
      home_attr = "name";
      home_alias = "none";
      uid_attr_map = "name";
      gid_attr_map = "name";
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

  users.groups.kanidm-authorized-keys = { };
  users.users.kanidm-authorized-keys = {
    description = "Kanidm authorized keys delegate";
    isSystemUser = true;
    group = "kanidm-authorized-keys";
  };

  services.openssh.settings = {
    AuthorizedKeysCommand = "${config.security.wrapperDir}/kanidm_ssh_authorizedkeys %u";
    AuthorizedKeysCommandUser = "kanidm-authorized-keys";
  };

  security.wrappers.kanidm_ssh_authorizedkeys = {
    owner = "root";
    group = "root";
    permissions = "a+rx";
    source = "${config.services.kanidm.package}/bin/kanidm_ssh_authorizedkeys";
  };

  systemd.services.kanidm = {
    after = [ "acme-${domain}.service" ];
    requires = [ "acme-${domain}.service" ];
  };

  systemd.services.kanidm-unixd-tasks.serviceConfig.BindPaths = [ "/users" ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
