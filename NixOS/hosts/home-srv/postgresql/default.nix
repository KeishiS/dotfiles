{ config, ... }:
let
  b2Target = config.sandi.backup.b2.targets.postgresql;
in
{
  imports = [
    ./server.nix
    ./apps
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
    ageRecipients = config.sandi.backup.ageRecipients;
    calendar = "Sun 02:00";
    upload = {
      enable = true;
      environmentFile = config.sops.secrets.postgresql-backup-b2-env.path;
      bucket = b2Target.bucket;
      prefix = b2Target.prefix;
    };
  };
}
