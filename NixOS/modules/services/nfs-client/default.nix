{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sandi.nfsClient;

  mapLine =
    _name: mount:
    "${mount.mountPoint} -fstype=${mount.fsType},${lib.concatStringsSep "," mount.options} ${mount.remote}";

  mapFile = pkgs.writeText "auto-nfs" (
    lib.concatStringsSep "\n" (lib.mapAttrsToList mapLine cfg.mounts) + "\n"
  );

  createMountPoints = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      _name: mount: "${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg mount.mountPoint}"
    ) cfg.mounts
  );
in
{
  options.sandi.nfsClient = {
    enable = lib.mkEnableOption "NFS client mounts via autofs";

    timeout = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Seconds until autofs unmounts idle NFS mounts.";
    };

    mounts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            mountPoint = lib.mkOption {
              type = lib.types.str;
              example = "/users";
              description = "Local absolute path managed by autofs.";
            };

            remote = lib.mkOption {
              type = lib.types.str;
              example = "192.168.10.17:/users";
              description = "Remote NFS export.";
            };

            fsType = lib.mkOption {
              type = lib.types.str;
              default = "nfs4";
              description = "Filesystem type used by autofs.";
            };

            options = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "rw"
                "vers=4.2"
                "hard"
                "intr"
              ];
              description = "NFS mount options used by autofs.";
            };
          };
        }
      );
      default = { };
      description = "NFS mounts managed through autofs direct maps.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = [ "nfs" ];

    environment.systemPackages = [ pkgs.nfs-utils ];

    services.autofs = {
      enable = true;
      timeout = cfg.timeout;
      autoMaster = ''
        /- file:${mapFile}
      '';
    };

    systemd.tmpfiles.rules = lib.mapAttrsToList (
      _name: mount: "d ${mount.mountPoint} 0755 root root -"
    ) cfg.mounts;

    systemd.services.autofs = {
      path = [
        pkgs.nfs-utils
        pkgs.util-linux
      ];
      preStart = createMountPoints;
    };
  };
}
