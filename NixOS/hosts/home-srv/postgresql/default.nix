{ config, ... }:
{
  imports = [
    ./server.nix
    ./backup.nix
  ];

  sops.secrets.db-sandi05-acme = {
    format = "yaml";
    sopsFile = ./secrets/cloudflare.enc.yaml;
    mode = "0400";
    owner = "acme";
    group = "acme";
  };

  sops.secrets.postgresql-backup-b2-env = {
    format = "binary";
    sopsFile = ./secrets/b2-credentials.env.enc;
    mode = "0400";
    owner = "postgres";
    group = "postgres";
  };

  services.homePostgresqlBackup = {
    enable = true;
    databases = [
      "postgres"
    ];
    ageRecipients = [
      "age1yubikey1qgauag3cngkm8u23h4r42ekn5ng2a7rmqqpspurz6kcuu9sqkhhgg62m0dc"
    ];
    calendar = "Sun 02:00";
    upload = {
      enable = true;
      environmentFile = config.sops.secrets.postgresql-backup-b2-env.path;
    };
  };
}
