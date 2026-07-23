{ config, ... }:
{
  # marginalis
  sops.secrets.marginalis-oidc-client-secret = {
    format = "yaml";
    sopsFile = ../secrets/marginalis.enc.yaml;
    owner = "marginalis";
    group = "marginalis";
  };

  sops.secrets.marginalis-root-password = {
    format = "yaml";
    sopsFile = ../secrets/marginalis.enc.yaml;
    owner = "marginalis";
    group = "marginalis";
  };

  services.marginalis = {
    enable = true;
    listenAddress = "0.0.0.0:3456";
    openFirewall = true;
    baseUrl = "https://marginalis.sandi05.com";

    oidc = {
      issuerUrl = "https://id.sandi05.com/oauth2/openid/marginalis";
      clientId = "marginalis";
      clientSecretFile = config.sops.secrets.marginalis-oidc-client-secret.path;
    };
    initialRootPasswordFile = config.sops.secrets.marginalis-root-password.path;
  };
}
