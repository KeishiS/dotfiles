{ config, ... }:
{
  sops.secrets.renkan-encryption-key = {
    format = "binary";
    sopsFile = ./secrets/renkan-encryption-key.enc;
    owner = "root";
    group = "root";
    mode = "400";
    restartUnits = [ "renkan.service" ];
  };

  sops.secrets.renkan-oidc-client-secret = {
    format = "binary";
    sopsFile = ./secrets/renkan-oidc-client-secret.enc;
    owner = "root";
    group = "root";
    mode = "400";
    restartUnits = [ "renkan.service" ];
  };

  sops.secrets.renkan-zotero-client-key = {
    format = "yaml";
    sopsFile = ./secrets/renkan-zotero-secret.enc.yaml;
    owner = "root";
    group = "root";
    mode = "400";
    restartUnits = [ "renkan.service" ];
  };

  sops.secrets.renkan-zotero-client-secret = {
    format = "yaml";
    sopsFile = ./secrets/renkan-zotero-secret.enc.yaml;
    owner = "root";
    group = "root";
    mode = "400";
    restartUnits = [ "renkan.service" ];
  };

  services.renkan = {
    enable = true;
    baseUrl = "https://renkan.sandi05.com/";
    allowedMarginalisUrls = [ "https://marginalis.sandi05.com/" ];
    listenAddress = "0.0.0.0:6789";
    encryptionKeyFile = config.sops.secrets.renkan-encryption-key.path;
    syncIntervalSeconds = 600;

    oidc = {
      issuerUrl = "https://id.sandi05.com/oauth2/openid/renkan";
      clientId = "renkan";
      clientSecretFile = config.sops.secrets.renkan-oidc-client-secret.path;
    };

    zoteroOAuth = {
      consumerKeyFile = config.sops.secrets.renkan-zotero-client-key.path;
      consumerSecretFile = config.sops.secrets.renkan-zotero-client-secret.path;
      allowGroupReadAccess = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 6789 ];
}
