{ ... }:
{
  # sops.secrets.cloudflared-cred = {
  #   sopsFile = ./secrets/cloudflared-cred.enc.json;
  #   mode = "0400";
  # };

  services.cloudflared = {
    enable = true;
    # tunnels = {
    #   "01ce2a27-2c48-4fc9-9bca-2e3c8af0cae5" = {
    #     credentialsFile = config.sops.secrets.cloudflared-cred.path;
    #     default = "http_status:404";
    #   };
    # };
  };
}
