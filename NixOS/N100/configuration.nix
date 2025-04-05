{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./ldap.nix
  ];

  networking.hostName = "NixOS-sandi-N100";
  system.stateVersion = "24.11";
}
