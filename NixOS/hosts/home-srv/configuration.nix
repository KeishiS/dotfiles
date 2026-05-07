{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # ./grafana.nix
    # ./cloudflared.nix
    # ./nginx.nix
    ./postgresql
    # ./myserv
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
  };

  services.libinput.enable = true;
  system.stateVersion = "25.11"; # Did you read the comment?
}
