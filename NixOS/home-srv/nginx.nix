{ ... }:
{
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    upstreams.gql-servers = {
      extraConfig = ''
        least_conn;
      '';
      servers = {
        "127.0.0.1:50001" = { };
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
      http3 = true;

      locations."/" = {
        proxyPass = "http://gql-servers";
        # root = "/var/www";
      };
    };
  };
}
