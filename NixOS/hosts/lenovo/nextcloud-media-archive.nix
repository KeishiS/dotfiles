{ config, lib, pkgs, ... }:
let
  account = "keishis";
  b2Target = config.sandi.backup.b2.targets.nextcloudMedia;
  sourceDir = "/storage/nextcloud/data/${account}/files/JellyfinImport";
  mediaDir = "/storage/jellyfin/media/${account}";
  archiveDir = "/storage/archive/nextcloud-media/encrypted/${account}";
  stateDir = "/var/lib/nextcloud-media-archive/state/${account}";
  minAgeMinutes = 10;
  recipientArgs = lib.concatMapStringsSep " " (
    recipient: "-r ${lib.escapeShellArg recipient}"
  ) config.sandi.backup.ageRecipients;
in
{
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

  users.users.nextcloud-media-archive = {
    isSystemUser = true;
    group = "nextcloud-media-archive";
    extraGroups = [
      "nextcloud"
      "jellyfin"
    ];
  };

  users.groups.nextcloud-media-archive = { };

  systemd.tmpfiles.rules = [
    "d /storage/jellyfin 0750 jellyfin jellyfin -"
    "d /storage/jellyfin/media 0750 jellyfin jellyfin -"
    "d ${mediaDir} 2770 jellyfin jellyfin -"
    "d /storage/archive 0750 nextcloud-media-archive nextcloud-media-archive -"
    "d /storage/archive/nextcloud-media 2770 nextcloud-media-archive nextcloud-media-archive -"
    "d /storage/archive/nextcloud-media/encrypted 2770 nextcloud-media-archive nextcloud-media-archive -"
    "d ${archiveDir} 2770 nextcloud-media-archive nextcloud-media-archive -"
    "d /var/lib/nextcloud-media-archive 0750 nextcloud-media-archive nextcloud-media-archive -"
    "d /var/lib/nextcloud-media-archive/state 2770 nextcloud-media-archive nextcloud-media-archive -"
    "d ${stateDir} 2770 nextcloud-media-archive nextcloud-media-archive -"
  ];

  systemd.services.nextcloud-media-archive = {
    description = "Copy Nextcloud videos to Jellyfin and create encrypted archives";
    after = [ "nextcloud-setup.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud-media-archive";
      Group = "nextcloud-media-archive";
      UMask = "0027";
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
