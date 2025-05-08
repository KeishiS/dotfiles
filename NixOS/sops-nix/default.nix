{ ... }:
{
  sops.secrets = {
    hosts = {
      format = "binary";
      sopsFile = ./hosts.enc;
    };
  };
}
