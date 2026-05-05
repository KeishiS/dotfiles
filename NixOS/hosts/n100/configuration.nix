{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nginx.nix
  ];

  networking.hostName = "NixOS-sandi-N100";
  system.stateVersion = "25.11";
}
