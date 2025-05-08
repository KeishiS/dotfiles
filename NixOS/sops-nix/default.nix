{ ... }:
{
  sops.secrets.hosts = {
    format = "binary";
    sopsFile = ./secrets/hosts.enc;
  };
}
