{ ... }:
{
  sops.secrets."sandi05-cloudflare-acme" = {
    format = "yaml";
    sopsFile = ./secrets/sandi05.enc.yaml;
    mode = "0400";
    owner = "acme";
    group = "acme";
  };
}
