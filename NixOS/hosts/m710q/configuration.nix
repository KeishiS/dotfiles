{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # ./open-webui.nix
  ];

  networking.hostName = "nixos-sandi-m710q";

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  environment.systemPackages = with pkgs; [
    arp-scan
  ];

  system.stateVersion = "26.05";
}
