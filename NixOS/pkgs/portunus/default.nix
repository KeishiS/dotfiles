{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 389 ];

  sops.secrets.keishi = {
    format = "binary";
    sopsFile = ./secrets/keishi.enc;
    mode = "0440";
    owner = "portunus";
    group = "nslcd";
  };
}
