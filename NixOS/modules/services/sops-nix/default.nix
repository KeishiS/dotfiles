{ ... }:
{
  # /etc/hosts
  sops.secrets.hosts = {
    format = "binary";
    sopsFile = ./secrets/hosts.enc;
    mode = "0444";
    path = "/etc/hosts";
  };
}
