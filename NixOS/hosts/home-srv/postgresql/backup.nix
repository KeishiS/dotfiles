{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.homePostgresqlBackup;
  backupLib = import ../../../modules/services/backup/lib.nix { inherit lib; };
  b2Cli = config.sandi.backup.b2.cliPackage;
  recipientArgs = backupLib.ageRecipientArgs cfg.ageRecipients;
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

    localRetention = lib.mkOption {
      type = lib.types.str;
      default = "1d";
      description = "Age after which local backup files under backupRoot are removed by systemd-tmpfiles.";
    };

    calendar = lib.mkOption {
      type = lib.types.str;
      default = "Sun 03:00";
      description = "systemd calendar expression for the backup timer.";
    };

    upload = {
      enable = lib.mkEnableOption "uploading encrypted PostgreSQL backups";

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Environment file containing B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY.
        '';
      };

      bucket = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Backblaze B2 bucket name.";
      };

      prefix = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Backblaze B2 object prefix.";
      };
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
      {
        assertion = !cfg.upload.enable || cfg.upload.environmentFile != null;
        message = "services.homePostgresqlBackup.upload.environmentFile must be set when upload is enabled.";
      }
      {
        assertion = !cfg.upload.enable || cfg.upload.bucket != "";
        message = "services.homePostgresqlBackup.upload.bucket must be set when upload is enabled.";
      }
      {
        assertion = !cfg.upload.enable || cfg.upload.prefix != "";
        message = "services.homePostgresqlBackup.upload.prefix must be set when upload is enabled.";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.backupRoot} 0700 postgres postgres ${cfg.localRetention}"
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
      }
      // lib.optionalAttrs cfg.upload.enable {
        EnvironmentFile = cfg.upload.environmentFile;
      };

      path =
        with pkgs;
        [
          age
          coreutils
          postgresql_18
          zstd
          age-plugin-yubikey
        ]
        ++ lib.optionals cfg.upload.enable [
          b2Cli
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

        # database 毎のdump
        ${lib.concatMapStringsSep "\n" dumpDatabase cfg.databases}

        # upload
        ${lib.optionalString cfg.upload.enable ''
          ${backupLib.b2RequiredEnv}
          ${backupLib.b2AccountInfoEnv}

          for file in "$backup_dir"/*.age; do
            ${backupLib.b2Upload {
              bucket = cfg.upload.bucket;
              source = ''"$file"'';
              destination = ''${lib.escapeShellArg cfg.upload.prefix}/"$timestamp/$(basename "$file")"'';
            }}
          done
        ''}
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
