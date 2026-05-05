{ ... }:
{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:9100"
              "192.168.10.4:9100"
            ];
          }
        ];
      }
      {
        job_name = "yace";
        metrics_path = "/metrics";
        static_configs = [
          {
            targets = [ "localhost:5000" ];
          }
        ];
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [
    9090
    9100
  ];

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "tcpstat"
      "systemd"
    ];
  };
}
