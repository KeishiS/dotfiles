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
    package = pkgs.nextcloud31;
    hostName = "storage.sandi05.com";
    config.adminpassFile = config.sops.secrets."nextcloud-adminpwd".path;
    config.dbtype = "sqlite";

    maxUploadSize = "10G";
    datadir = "/nfs/nextcloud";
    settings = {
      trusted_domains = [ "192.168.10.17" ];
      trusted_proxies = [
        "192.168.10.13"
        "240b:10:c040:9f00:d6ea:ecde:c4ea:da28"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
