{
  imports = [
    ./server.nix
  ];

  sops.secrets.db-sandi05-acme = {
    format = "yaml";
    sopsFile = ./secrets/cloudflare.enc.yaml;
    mode = "0400";
    owner = "acme";
    group = "acme";
  };
}
