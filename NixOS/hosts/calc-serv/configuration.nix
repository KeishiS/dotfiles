{ pkgs, ... }:
let
  vaultwardenUid = 951;
  vaultwardenGid = 951;
  nextcloudUid = 952;
  nextcloudGid = 952;
  jellyfinUid = 953;
  jellyfinGid = 953;
  nextcloudMediaArchiveUid = 954;
  nextcloudMediaArchiveGid = 954;
  nextcloudMediaArchiveRetention = "1d";
in
{
  imports = [
    ./hardware-configuration.nix
    ./agent-sandbox.nix
    ./nfs.nix
    ./kanidm.nix
    ./nextcloud.nix
  ];

  networking.hostName = "nixos-sandi-calc-serv";

  environment.systemPackages = with pkgs; [
    btrfs-progs
    clinfo
    nfs-utils
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    smartmontools
  ];

  services.libinput.enable = true;

  users.users.keishis.extraGroups = [
    "render"
    "video"
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

  users.groups.nextcloud.gid = nextcloudGid;
  users.users.nextcloud = {
    isSystemUser = true;
    uid = nextcloudUid;
    group = "nextcloud";
  };

  users.groups.jellyfin.gid = jellyfinGid;
  users.users.jellyfin = {
    isSystemUser = true;
    uid = jellyfinUid;
    group = "jellyfin";
  };

  users.groups.nextcloud-media-archive.gid = nextcloudMediaArchiveGid;
  users.users.nextcloud-media-archive = {
    isSystemUser = true;
    uid = nextcloudMediaArchiveUid;
    group = "nextcloud-media-archive";
  };

  systemd.tmpfiles.rules = [
    "d /storage/vaultwarden 0700 ${toString vaultwardenUid} ${toString vaultwardenGid} -"
    "d /storage/vaultwarden/backup 0700 ${toString vaultwardenUid} ${toString vaultwardenGid} -"
    "d /storage/nextcloud 0750 ${toString nextcloudUid} ${toString nextcloudGid} -"
    "d /storage/nextcloud/config 0750 ${toString nextcloudUid} ${toString nextcloudGid} -"
    "d /storage/jellyfin 0750 ${toString jellyfinUid} ${toString jellyfinGid} -"
    "d /storage/jellyfin/media 0750 ${toString jellyfinUid} ${toString jellyfinGid} -"
    "d /storage/jellyfin/media/nobuta05 2770 ${toString jellyfinUid} ${toString jellyfinGid} -"
    "d /storage/archive 0750 ${toString nextcloudMediaArchiveUid} ${toString nextcloudMediaArchiveGid} -"
    "d /storage/archive/nextcloud-media 2770 ${toString nextcloudMediaArchiveUid} ${toString nextcloudMediaArchiveGid} -"
    "d /storage/archive/nextcloud-media/encrypted 2770 ${toString nextcloudMediaArchiveUid} ${toString nextcloudMediaArchiveGid} ${nextcloudMediaArchiveRetention}"
    "d /storage/archive/nextcloud-media/encrypted/nobuta05 2770 ${toString nextcloudMediaArchiveUid} ${toString nextcloudMediaArchiveGid} ${nextcloudMediaArchiveRetention}"
  ];

  system.stateVersion = "26.05";
}
