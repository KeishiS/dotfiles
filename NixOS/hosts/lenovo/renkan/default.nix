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

  services.renkan = {
    enable = true;
    baseUrl = "https://renkan.sandi05.com/";
    allowedMarginalisUrls = [ "https://marginalis.sandi05.com/" ];
    listenAddress = "0.0.0.0:6789";
    encryptionKeyFile = config.sops.secrets.renkan-encryption-key.path;
    syncIntervalSeconds = 600;
  };
}
