# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../pkgs/netdata-client
    # ./ldap.nix
  ];

  networking.hostName = "nixos-keishis-home";
  # networking.firewall.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };
  environment.systemPackages = with pkgs; [
    asunder
    gnome-sound-recorder
    kdePackages.kdenlive
  ];

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
  };

  services.libinput.enable = true;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
