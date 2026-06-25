{
  config,
  lib,
  pkgs,
  ...
}:
let
  nextcloudAccount = "bcd76067022f35e3705357b03a527034b3aa6c7e6cde28983b73536079ffd658";
  mediaAccount = "nobuta05";
  nextcloudGid = 952;
  archiveUid = 954;
  archiveGid = 954;
  backupLib = import ../../modules/services/backup/lib.nix { inherit lib; };
  b2Target = config.sandi.backup.b2.targets.nextcloudMedia;
  sourceDir = "/storage/nextcloud/data/${nextcloudAccount}/files/JellyfinImport";
  mediaDir = "/storage/jellyfin/media/${mediaAccount}";
  archiveDir = "/storage/archive/nextcloud-media/encrypted/${mediaAccount}";
  stateDir = "/var/lib/nextcloud-media-archive/state/${mediaAccount}";
  minAgeMinutes = 10;
  localArchiveRetention = "1d";
  recipientArgs = backupLib.ageRecipientArgs config.sandi.backup.ageRecipients;
in
{
  sops.secrets.nextcloud-media-b2-env = {
    format = "binary";
    sopsFile = ./secrets/nextcloud-media-b2.env.enc;
    owner = "nextcloud-media-archive";
    group = "nextcloud-media-archive";
    mode = "0400";
  };

  assertions = [
    {
      assertion = config.sandi.backup.ageRecipients != [ ];
      message = "sandi.backup.ageRecipients must not be empty.";
    }
    {
      assertion = b2Target.bucket != "" && b2Target.prefix != "";
      message = "sandi.backup.b2.targets.nextcloudMedia must define bucket and prefix.";
    }
  ];

  users.groups.nextcloud.gid = nextcloudGid;
  users.groups.nextcloud-media-archive.gid = archiveGid;
  users.users.nextcloud-media-archive = {
    isSystemUser = true;
    uid = archiveUid;
    group = "nextcloud-media-archive";
    extraGroups = [
      "nextcloud"
      "jellyfin"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nextcloud-media-archive 0750 nextcloud-media-archive nextcloud-media-archive -"
    "d /var/lib/nextcloud-media-archive/state 2770 nextcloud-media-archive nextcloud-media-archive -"
    "d ${stateDir} 2770 nextcloud-media-archive nextcloud-media-archive -"
  ];

  systemd.services.nextcloud-media-archive = {
    description = "Copy Nextcloud videos to Jellyfin and create encrypted archives";
    after = [
      "network-online.target"
      "autofs.service"
    ];
    wants = [
      "network-online.target"
      "autofs.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud-media-archive";
      Group = "nextcloud-media-archive";
      UMask = "0027";
      EnvironmentFile = config.sops.secrets.nextcloud-media-b2-env.path;
      StateDirectory = "nextcloud-media-archive";
      StateDirectoryMode = "0750";
      ReadOnlyPaths = [ "/storage/nextcloud" ];
      ReadWritePaths = [
        "/storage/jellyfin"
        "/storage/archive/nextcloud-media"
        "/var/lib/nextcloud-media-archive"
      ];
    };

    path = with pkgs; [
      age
      age-plugin-yubikey
      coreutils
      findutils
      gnutar
      zstd
      config.sandi.backup.b2.cliPackage
    ];

    script = ''
      set -euo pipefail

      source_dir=${lib.escapeShellArg sourceDir}
      media_dir=${lib.escapeShellArg mediaDir}
      archive_dir=${lib.escapeShellArg archiveDir}
      state_dir=${lib.escapeShellArg stateDir}

      if [ ! -d "$source_dir" ]; then
        echo "source directory does not exist: $source_dir"
        exit 0
      fi

      find "$source_dir" -type f \
        \( -iname '*.mp4' -o -iname '*.mkv' \) \
        -mmin +${toString minAgeMinutes} \
        -print0 |
        while IFS= read -r -d "" src; do
          rel="''${src#"$source_dir"/}"
          marker="$state_dir/$rel.done"

          if [ -e "$marker" ]; then
            continue
          fi

          dest="$media_dir/$rel"
          archive="$archive_dir/$rel.tar.zst.age"

          echo "processing: $rel"
          install -d -m 2770 "$(dirname "$dest")"
          install -m 0640 "$src" "$dest"

          mkdir -p "$(dirname "$archive")"
          tar -C "$(dirname "$src")" -cf - "$(basename "$src")" \
            | zstd --threads=1 \
            | age ${recipientArgs} \
            > "$archive"
          echo "created encrypted archive: $archive"

          ${backupLib.b2RequiredEnv}

          ${backupLib.b2AccountInfoEnv}
          ${backupLib.b2Upload {
            bucket = b2Target.bucket;
            source = ''"$archive"'';
            destination = ''${lib.escapeShellArg b2Target.prefix}/"$rel.tar.zst.age"'';
          }}
          echo "uploaded encrypted archive: ${b2Target.prefix}/$rel.tar.zst.age"

          install -D -m 0644 /dev/null "$marker"
        done
    '';
  };

  systemd.timers.nextcloud-media-archive = {
    description = "Run Nextcloud media archive import";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
      Unit = "nextcloud-media-archive.service";
    };
  };
}
