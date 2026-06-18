{ config, ... }:
let
  b2Target = config.sandi.backup.b2.targets.postgresql;
in
{
  imports = [
    ./server.nix
    ./pgbouncer.nix
    ./apps
    ./backup.nix
  ];

  sops.secrets.sandi05-cloudflare-acme = {
    format = "yaml";
    sopsFile = ../../../secrets/cloudflare-sandi05-acme.enc.yaml;
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
