{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.homePostgresqlBackup;
  recipientArgs = lib.concatMapStringsSep " " (
    recipient: "-r ${lib.escapeShellArg recipient}"
  ) cfg.ageRecipients;
  dumpDatabase = database: ''
    database=${lib.escapeShellArg database}
    ${pkgs.postgresql_18}/bin/pg_dump --format=custom --dbname=${lib.escapeShellArg database} \
      | ${pkgs.zstd}/bin/zstd --threads=1 \
      | ${pkgs.age}/bin/age ${recipientArgs} \
      > "$backup_dir/$database.dump.zst.age"
  '';
in
{
  options.services.homePostgresqlBackup = {
    enable = lib.mkEnableOption "home-srv PostgreSQL logical backups";

    databases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "PostgreSQL databases to dump with pg_dump.";
    };

    ageRecipients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "age recipients used to encrypt backup artifacts.";
    };

    backupRoot = lib.mkOption {
      type = lib.types.path;
      default = "/var/backups/postgresql";
      description = "Directory where encrypted PostgreSQL backups are stored.";
    };

    calendar = lib.mkOption {
      type = lib.types.str;
      default = "Sun 03:00";
      description = "systemd calendar expression for the backup timer.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.databases != [ ];
        message = "services.homePostgresqlBackup.databases must not be empty.";
      }
      {
        assertion = cfg.ageRecipients != [ ];
        message = "services.homePostgresqlBackup.ageRecipients must not be empty.";
      }
      {
        assertion = lib.all (
          database: builtins.match "[A-Za-z0-9_][A-Za-z0-9_-]*" database != null
        ) cfg.databases;
        message = "services.homePostgresqlBackup.databases may only contain letters, digits, underscores, and hyphens, and must not start with a hyphen.";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.backupRoot} 0700 postgres postgres -"
    ];

    systemd.services.home-postgresql-backup = {
      description = "Create encrypted PostgreSQL logical backups";
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        UMask = "0077";
        StateDirectory = "postgresql-backup";
        StateDirectoryMode = "0700";
        ReadWritePaths = [ cfg.backupRoot ];
      };

      path = with pkgs; [
        age
        coreutils
        postgresql_18
        zstd
        age-plugin-yubikey
      ];

      script = ''
        set -euo pipefail

        timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
        backup_dir=${lib.escapeShellArg cfg.backupRoot}/"$timestamp"
        install -d -m 0700 "$backup_dir"

        # cluster 全体の設定を dump
        pg_dumpall --globals-only \
          | zstd --threads=1 \
          | age ${recipientArgs} \
          > "$backup_dir/globals.sql.zst.age"

        ${lib.concatMapStringsSep "\n" dumpDatabase cfg.databases}
      '';
    };

    systemd.timers.home-postgresql-backup = {
      description = "Run encrypted PostgreSQL logical backups";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.calendar;
        Persistent = true;
        Unit = "home-postgresql-backup.service";
      };
    };
  };
}
