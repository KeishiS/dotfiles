{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./postgresql
    ../../modules/services/kanidm-client
    ../../modules/services/nfs-client
  ];

  networking.hostName = "nixos-keishis-home";
  networking.hostFiles = [
    ./hosts.local
  ];

  environment.systemPackages = with pkgs; [
    asunder
    gnome-sound-recorder
    kdePackages.kdenlive
  ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  services.libinput.enable = true;

  sandi.nfsClient = {
    enable = true;
    mounts.users = {
      mountPoint = "/users";
      remote = "192.168.10.17:/users";
    };
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
