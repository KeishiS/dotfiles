{ config, pkgs, ... }:
{
  sops.secrets.keishis-password = {
    format = "yaml";
    sopsFile = ../../secrets/user-passwords.enc.yaml;
    key = "keishis";
    neededForUsers = true;
  };

  users.users.keishis = {
    isNormalUser = true;
    home = "/home/keishis";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.keishis-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEyh4Y1n0kJy3zfPZm2sWilYOVf/nC0Ifvh7F95/1H6 openpgp:0xBE9282EA"
    ];
  };
}
