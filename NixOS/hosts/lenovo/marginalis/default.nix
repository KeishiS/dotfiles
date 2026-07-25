{ config, ... }:
{
  # marginalis
  sops.secrets.marginalis-oidc-client-secret = {
    format = "yaml";
    sopsFile = ../secrets/marginalis.enc.yaml;
    owner = "marginalis";
    group = "marginalis";
  };

  services.marginalis = {
    enable = true;
    mcp = {
      enable = true;
      allowedOrigins = [
        "https://chatgpt.com"
        "https://claude.ai"
      ];
    };
    listenAddress = "0.0.0.0:3456";
    openFirewall = true;
    baseUrl = "https://marginalis.sandi05.com";
    backupDirectory = "/storage/marginalis/backup";

    oidc = {
      issuerUrl = "https://id.sandi05.com/oauth2/openid/marginalis";
      clientId = "marginalis";
      clientSecretFile = config.sops.secrets.marginalis-oidc-client-secret.path;
    };
  };
}
