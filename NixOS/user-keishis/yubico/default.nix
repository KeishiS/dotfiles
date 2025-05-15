{ config, ... }:
{
  sops.secrets.u2f_keys = {
    format = "binary";
    sopsFile = ./secrets/u2f_keys;
    path = "${config.home.homeDirectory}/.config/Yubico/u2f_keys";
  };
}
