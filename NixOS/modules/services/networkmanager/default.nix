{ lib, pkgs, ... }:
let
  connectDir = ./secrets;
  encFiles = lib.attrNames (builtins.readDir connectDir);

  removeEnc = name: lib.removeSuffix ".enc" name;
in
{
  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    wifi.backend = "iwd";
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-vpnc
    ];
  };

  sops.secrets = lib.listToAttrs (
    map (filename: {
      name = removeEnc filename;
      value = {
        format = "ini";
        sopsFile = connectDir + "/${filename}";
        path = "/var/lib/iwd/${removeEnc filename}";
        owner = "root";
        group = "root";
        mode = "0600";
      };
    }) encFiles
  );
}
