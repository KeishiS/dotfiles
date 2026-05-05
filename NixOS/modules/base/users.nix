{ pkgs, ... }:
{
  users.users.keishis = {
    isNormalUser = true;
    home = "/home/keishis";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    initialHashedPassword = "$6$Rk3ZM8V5JpDmaggo$tADvEPoECdw7PE2JZebqch3rpsrDJAZ40JZt1aK6HpfZ9psXDy7I3XwCtoVCaMhFY8cJt.YVJuFQIExiwJgLs.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEyh4Y1n0kJy3zfPZm2sWilYOVf/nC0Ifvh7F95/1H6 openpgp:0xBE9282EA"
    ];
  };
}
