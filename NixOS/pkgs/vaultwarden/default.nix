{ config, ... }:
{
  sops.secrets.vwEnv = {
    format = "binary";
    sopsFile = ./secrets/vw.env.enc;
    mode = "0440";
  };

  services.vaultwarden = {
    enable = true;
    domain = "info.sandi05.com";
    backupDir = "/storage/vaultwarden/backup";
    environmentFile = config.sops.secrets.vwEnv.path;
  };
}
