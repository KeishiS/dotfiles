{ lib, pkgs, ... }:
{
  networking.networkmanager = {
    enable = true;
    wifi.macAddress = lib.mkDefault "permanent";
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-vpnc
    ];
  };
}
