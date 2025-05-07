# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./ldap.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

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
  ];

  services.libinput.enable = true;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  system.stateVersion = "24.11"; # Did you read the comment?
}
