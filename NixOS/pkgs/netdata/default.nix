{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 19999 ];
  services.netdata = {
    enable = true;
    config = {
      global = {
        "memory mode" = "ram";
        "update every" = 5;
        "timezone" = "Asia/Tokyo";
      };
      db = {
        mode = "none";
      };
    };
  };
}
