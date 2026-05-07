{ pkgs, ... }:
{
  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-vpnc
    ];
  };
}
