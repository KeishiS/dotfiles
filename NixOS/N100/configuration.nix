{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./ldap.nix
    ./nginx.nix
  ];

  networking.hostName = "NixOS-sandi-N100";
  system.stateVersion = "24.11";
}
