{ config, ... }:
let
  tunnelId = "29ed1087-fdd8-4a95-85d7-ef522319cf28";
in
{
  sops.secrets.dev-tunnel = {
    sopsFile = ./secrets/dev-tunnel.enc.json;
    format = "json";
    key = "";
    mode = "0400";
  };

  services.cloudflared = {
    enable = true;
    tunnels.${tunnelId} = {
      credentialsFile = config.sops.secrets.dev-tunnel.path;
      default = "http_status:404";
      ingress = {
        "dev-api.koyomado.com" = "http://127.0.0.1:8808";
      };
    };
  };
}
