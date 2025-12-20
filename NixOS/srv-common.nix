{
  pkgs,
  ...
}:
{
  security.sudo.wheelNeedsPassword = false;

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

  environment.systemPackages = with pkgs; [
    julia_110-bin
    lapack
    mackerel-agent
    nfs-utils
    uv
  ];

  programs.starship.enable = true;

  /*
    programs.gnupg.agent = {
      pinentryPackage = pkgs.pinentry-curses;
    };
  */

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.10.0/24"
      "240b:10:c040:9f00::/64"
    ];
    bantime = "24h";
    maxretry = 5;
  };
}
