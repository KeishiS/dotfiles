{ config, pkgs, ... }:
{
  sops.secrets."nextcloud-adminpwd" = {
    format = "binary";
    sopsFile = ./secrets/nextcloud-adminpwd.enc;
    mode = "400";
    owner = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "storage.sandi05.com";
    config.adminpassFile = config.sops.secrets."nextcloud-adminpwd".path;
    config.dbtype = "sqlite";

    maxUploadSize = "10G";
    datadir = "/storage/nextcloud";
    settings = {
      trusted_domains = [ "192.168.10.17" ];
      trusted_proxies = [
        "192.168.10.31"
        "192.168.10.25"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
