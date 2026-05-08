{ config, pkgs, ... }:
{
  sops.secrets.sandi-password = {
    format = "yaml";
    sopsFile = ../../secrets/user-passwords.enc.yaml;
    key = "sandi";
    neededForUsers = true;
  };

  users.users.sandi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.sandi-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
    ];
  };
}
