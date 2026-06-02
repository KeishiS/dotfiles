{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos-sandi-m710q";

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  system.stateVersion = "26.05";
}
