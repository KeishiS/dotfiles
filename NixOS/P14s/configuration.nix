{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./common.nix
  ];

  networking.hostName = "NixOS-keishis-P14s";

  services.libinput.enable = true; # enable touchpad support

  system.stateVersion = "25.11";
}
