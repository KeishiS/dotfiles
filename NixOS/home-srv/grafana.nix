{ ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 3000;
    };

    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        url = "http://192.168.10.17:9090";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
