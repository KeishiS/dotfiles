{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos-sandi-m710q";

  system.stateVersion = "26.05";
}
