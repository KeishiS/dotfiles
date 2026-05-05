{ ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 3000;
    };

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://192.168.10.17:9090";
          }
          /*
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:3100";
            }
          */
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
