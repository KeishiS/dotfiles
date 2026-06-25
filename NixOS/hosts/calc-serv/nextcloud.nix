{
  config,
  pkgs,
  ...
}:
let
  nextcloudPackage = pkgs.nextcloud33;
  nextcloudOcc = "${config.services.nextcloud.occ}/bin/nextcloud-occ";
in
{
  sops.secrets."nextcloud-adminpwd" = {
    format = "binary";
    sopsFile = ./secrets/nextcloud-adminpwd.enc;
    mode = "0400";
    owner = "nextcloud";
  };

  sops.secrets.nextcloud-smtp-password = {
    format = "binary";
    sopsFile = ./secrets/nextcloud-smtp-password.enc;
    mode = "0400";
    owner = "nextcloud";
  };

  sops.secrets.nextcloud-oidc-client-secret = {
    format = "binary";
    sopsFile = ./secrets/nextcloud-oidc-client-secret.enc;
    mode = "0400";
    owner = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = nextcloudPackage;
    hostName = "storage.sandi05.com";
    appstoreEnable = false;
    config.adminpassFile = config.sops.secrets."nextcloud-adminpwd".path;
    config.dbtype = "sqlite";

    extraApps = {
      inherit (nextcloudPackage.packages.apps) user_oidc;
    };
    extraAppsEnable = false;

    secrets.mail_smtppassword = config.sops.secrets.nextcloud-smtp-password.path;

    maxUploadSize = "10G";
    datadir = "/storage/nextcloud";
    settings = {
      trusted_domains = [ "storage.sandi05.com" ];
      trusted_proxies = [ "192.168.100.31" ];
      allow_local_remote_servers = true;
      overwriteprotocol = "https";
      "overwrite.cli.url" = "https://storage.sandi05.com";

      mail_smtpmode = "smtp";
      mail_smtphost = "smtp.resend.com";
      mail_smtpport = 465;
      mail_smtpsecure = "ssl";
      mail_smtpauth = true;
      mail_smtpname = "resend";

      mail_from_address = "nextcloud";
      mail_domain = "mail.sandi05.com";
    };
  };

  services.nginx.virtualHosts."storage.sandi05.com" = {
    locations."/" = {
      extraConfig = ''
        client_max_body_size 10G;
        proxy_read_timeout    3600s;
        proxy_send_timeout    3600s;
        proxy_connect_timeout 3600s;
        send_timeout          3600s;
      '';
    };
  };

  systemd.services.nextcloud-kanidm-oidc = {
    description = "Configure Kanidm OpenID Connect provider for Nextcloud";
    wantedBy = [ "multi-user.target" ];
    requires = [ "nextcloud-setup.service" ];
    after = [ "nextcloud-setup.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";
      Group = "nextcloud";
      # nextcloud-occ checks CREDENTIALS_DIRECTORY before deciding whether to
      # spawn systemd-run for runtime secrets. Keep this even though the script
      # does not read mail_smtppassword directly.
      LoadCredential = [
        "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}"
      ];
    };

    script = ''
      ${nextcloudOcc} app:enable user_oidc
      ${nextcloudOcc} user_oidc:provider kanidm \
        --clientid="nextcloud" \
        --clientsecret-file="${config.sops.secrets.nextcloud-oidc-client-secret.path}" \
        --discoveryuri="https://id.sandi05.com/oauth2/openid/nextcloud/.well-known/openid-configuration" \
        --scope="openid email profile groups_name" \
        --mapping-groups="groups_name" \
        --group-provisioning=0 \
        --group-whitelist-regex="/^server-users$/" \
        --group-restrict-login-to-whitelist=0
    '';
  };
}
