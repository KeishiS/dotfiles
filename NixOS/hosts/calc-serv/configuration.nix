{ pkgs, ... }:
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

  system.stateVersion = "26.05";
}
