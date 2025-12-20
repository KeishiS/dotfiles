{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nginx.nix
    ../pkgs/ldap
  ];

  networking.hostName = "NixOS-sandi-N100";
  system.stateVersion = "25.11";
}
