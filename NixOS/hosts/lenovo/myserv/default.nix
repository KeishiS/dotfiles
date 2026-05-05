{ config, ... }:
{
  imports = [
    ./workers.nix
  ];

  sops.secrets."keylytix/resend" = {
    sopsFile = ./secrets/keylytix.enc.yaml;
    owner = "grafana";
    group = "grafana";
    mode = "0400";
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "192.168.10.17";
      http_port = 3000;
    };
    settings.smtp = {
      enabled = true;
      host = "smtp.resend.com:465";
      user = "resend";
      password = "$__file{${config.sops.secrets."keylytix/resend".path}}";
      from_address = "grafana@mail.sandi05.com";
      from_name = "Grafana";
      startTLS_policy = "MandatoryStartTLS";
    };

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://localhost:3100";
          }
        ];
      };

      alerting.contactPoints.settings = {
        apiVersion = 1;
        contactPoints = [
          {
            orgId = 1;
            name = "email-default";
            receivers = [
              {
                uid = "nobuta05";
                type = "email";
                settings.addresses = "nobuta05@gmail.com";
              }
              {
                uid = "sandybox";
                type = "email";
                settings.addresses = "sandybox05@gmail.com";
              }
            ];
          }
        ];
      };

      /*
        alerting.rules.settings = {
          apiVersion = 1;
          groups = [
            {
              orgId = 1;
              name = "processes";
              folder = "infra";
              interval = "1m";
              rules = [
                {
                  uid = "graphql-gateway";
                  title = "number of graphql-gateways";
                  condition = "C";
                  data = [
                      {

                      }
                  ];
                }
              ];
            }
          ];
        };
      */
    };
  };

  #------------------------------------------------------
  # Loki
  #------------------------------------------------------
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_port = 3100;

      common = {
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      storage_config.filesystem.directory = "/var/lib/loki/chunks";
      limits_config.allow_structured_metadata = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    3000 # grafana
    3100 # Loki
  ];
}
