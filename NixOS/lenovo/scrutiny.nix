{ ... }:
{
  services.scrutiny = {
    enable = true;
    openFirewall = true;
    settings = {
      web.listen.port = 12345;
    };

    collector.schedule = "hourly";
    collector.settings = {
      version = 1;
      devices = [
        {
          device = "/dev/sda";
          type = [ "sat,auto" ];
        }
        {
          device = "/dev/sdb";
          type = [ "sat,auto" ];
        }
      ];
    };
  };
}
