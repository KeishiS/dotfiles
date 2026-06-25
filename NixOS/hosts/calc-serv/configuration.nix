{ pkgs, ... }:
let
  vaultwardenUid = 951;
  vaultwardenGid = 951;
in
{
  imports = [
    ./hardware-configuration.nix
    ./nfs.nix
    ./kanidm.nix
  ];

  networking.hostName = "nixos-sandi-calc-serv";

  environment.systemPackages = with pkgs; [
    btrfs-progs
    nfs-utils
    smartmontools
  ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/storage" ];
    interval = "monthly";
  };

  users.groups.vaultwarden.gid = vaultwardenGid;
  users.users.vaultwarden = {
    isSystemUser = true;
    uid = vaultwardenUid;
    group = "vaultwarden";
  };

  systemd.tmpfiles.rules = [
    "d /storage/vaultwarden 0700 ${toString vaultwardenUid} ${toString vaultwardenGid} -"
    "d /storage/vaultwarden/backup 0700 ${toString vaultwardenUid} ${toString vaultwardenGid} -"
  ];

  system.stateVersion = "26.05";
}
