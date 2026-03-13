{ config, ... }:
{
  sops.secrets.cloudflared-creds = {
    format = "binary";
    sopsFile = ./secrets/cloudflared-cred.json.enc;
    mode = "0400";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "01ce2a27-2c48-4fc9-9bca-2e3c8af0cae5" = {
        credentialsFile = config.sops.secrets.cloudflared-creds.path;
        ingress = {
          "gql.keylytix.net" = "http://localhost";
        };
        default = "http_status:404";
      };
    };
  };
}
