{ config, lib, ... }:
let
  vaultwardenUid = 951;
  vaultwardenGid = 951;
in
{
  sops.secrets.vwEnv = {
    format = "binary";
    sopsFile = ./secrets/vw.env.enc;
    mode = "0440";
  };

  services.vaultwarden = {
    enable = true;
    domain = "key.sandi05.com";
    backupDir = "/storage/vaultwarden/backup";
    environmentFile = config.sops.secrets.vwEnv.path;
    config = {
      DOMAIN = "https://key.sandi05.com";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8000;

      SIGNUPS_ALLOWED = false; # 新規サインアップ無効
      INVITATIONS_ALLOWED = true; # 招待したユーザは可
      SIGNUPS_VERIFY = true;

      SSO_ENABLED = true;
      SSO_ONLY = false;
      SSO_SIGNUPS_MATCH_EMAIL = true;
      SSO_AUTHORITY = "https://id.sandi05.com/oauth2/openid/vaultwarden";
      SSO_SCOPES = "email profile";
      SSO_PKCE = true;
      SSO_CLIENT_ID = "vaultwarden";

      ENABLE_WEBSOCKET = true;
      PUSH_ENABLED = true;

      SMTP_HOST = "smtp.resend.com";
      SMTP_PORT = 465;
      SMTP_SECURITY = "force_tls";
      SMTP_USERNAME = "resend";
      SMTP_FROM = "noreply@mail.sandi05.com";
      SMTP_FROM_NAME = "vaultwarden";
      SMTP_DEBUG = false;
    };
  };

  users.groups.vaultwarden.gid = vaultwardenGid;
  users.users.vaultwarden.uid = vaultwardenUid;

  systemd.services.backup-vaultwarden.wantedBy = lib.mkForce [ ];

  networking.firewall.allowedTCPPorts = [ 8000 ];
}
