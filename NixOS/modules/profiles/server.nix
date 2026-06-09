{
  pkgs,
  ...
}:
{
  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    julia_110-bin
    lapack
    # mackerel-agent
    nfs-utils
    uv
  ];

  programs.starship.enable = true;

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.100.0/24"
      "240b:10:c040:9f00::/64"
      "100.69.86.116/32"
    ];
    bantime = "24h";
    maxretry = 5;
  };
}
