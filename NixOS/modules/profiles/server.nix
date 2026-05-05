{
  pkgs,
  ...
}:
{
  security.sudo.wheelNeedsPassword = false;

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
