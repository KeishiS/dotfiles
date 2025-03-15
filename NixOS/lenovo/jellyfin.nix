{ ... }:
{
  services.jellyfin = {
    enable = true;
    dataDir = "/nfs/jellyfin";
    openFirewall = true;
  };
}
