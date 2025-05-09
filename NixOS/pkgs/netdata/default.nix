{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 19999 ];

  services.netdata = {
    enable = true;
    package = pkgs.netdata.override { withCloudUi = true; };
    config = {
      "memory mode" = "ram";
    };
  };
}
