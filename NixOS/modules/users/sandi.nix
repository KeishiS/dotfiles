{ pkgs, ... }:
{
  users.users.sandi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    # `mkpasswd -m sha-512`
    initialHashedPassword = "$6$ooF34UYoB/VlBMyE$ifIIU4dmFNwgPTsvP5rNQ4LMR/D/rU5XkxvZJa73vi4TbjZSZBGSBitXFlJFugBgVTgH5zJ9rhdpayy4Sgrei/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
    ];
  };
}
