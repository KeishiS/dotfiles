{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./postgresql
    ./myserv1
    # ../../modules/services/kanidm-client
    ../../modules/services/nfs-client
  ];

  networking.hostName = "nixos-keishis-home";

  environment.systemPackages = with pkgs; [
    asunder
    gnome-sound-recorder
    kdePackages.kdenlive
  ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  services.libinput.enable = true;

  services.xrdp = {
    enable = true;
    openFirewall = false;
    defaultWindowManager = "${pkgs.i3}/bin/i3";
  };

  sandi.nfsClient = {
    enable = true;
    mounts.users = {
      mountPoint = "/users";
      remote = "calc-serv.sandi05.com:/users";
    };
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
