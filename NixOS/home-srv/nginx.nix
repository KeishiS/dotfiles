{ ... }:
{
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    # recommendedProxySettings = true;

    upstreams.graphql-gateways = {
      extraConfig = ''
        least_conn;
      '';
      servers = {
        "127.0.0.1:50001" = { };
        "127.0.0.1:50002" = { };
      };
    };

    upstreams.auth-services = {
      extraConfig = ''
        least_conn;
      '';
      servers = {
        "127.0.0.1:51001" = { };
        "127.0.0.1:51002" = { };
      };
    };

    upstreams.user-query-services = {
      extraConfig = ''
        least_conn;
      '';
      servers = {
        "127.0.0.1:52001" = { };
        "127.0.0.1:52002" = { };
      };
    };

    upstreams.user-command-services = {
      extraConfig = ''
        least_conn;
      '';
      servers = {
        "127.0.0.1:53001" = { };
        "127.0.0.1:53002" = { };
      };
    };

    virtualHosts."gql.keylytix.net" = {
      serverName = "gql.keylytix.net";
      listen = [
        {
          addr = "127.0.0.1";
          port = 80;
        }
        {
          addr = "[::1]";
          port = 80;
        }
      ];
      http2 = true;

      locations."/" = {
        proxyPass = "http://graphql-gateways";
        # root = "/var/www";
      };
    };

    virtualHosts."keylytix-auth-service" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 51000;
        }
        {
          addr = "[::1]";
          port = 51000;
        }
      ];
      extraConfig = ''
        http2 on;
      '';
      locations."/" = {
        extraConfig = ''
          grpc_pass grpc://auth-services;
        '';
      };
    };

    virtualHosts."keylytix-user-query-service" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 52000;
        }
        {
          addr = "[::1]";
          port = 52000;
        }
      ];
      extraConfig = ''
        http2 on;
      '';
      locations."/" = {
        extraConfig = ''
          grpc_pass grpc://user-query-services;
        '';
      };
    };

    virtualHosts."keylytix-user-command-service" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 53000;
        }
        {
          addr = "[::1]";
          port = 53000;
        }
      ];
      extraConfig = ''
        http2 on;
      '';
      locations."/" = {
        extraConfig = ''
          grpc_pass grpc://user-command-services;
        '';
      };
    };
  };
}
