{ lib, ... }:
{
  networking.firewall.allowedTCPPorts = [ 389 ];
  # portunus uses 8080 port

  sops.secrets.keishi = {
    format = "binary";
    sopsFile = ./secrets/keishi.enc;
    path = "/run/sops-nix/homelab/keishi";
    mode = "0440";
    owner = "portunus";
    # group = "nslcd";
  };

  sops.secrets.techadmin = {
    format = "binary";
    sopsFile = lib.mkDefault ./secrets/techadmin.enc;
    path = "/run/sops-nix/homelab/techadmin";
    mode = "0440";
    owner = lib.mkDefault "portunus";
    # group = "nslcd";
  };

  services.portunus = {
    enable = true;
    domain = "sandi05.com";
    ldap.suffix = "dc=sandi05,dc=com";
    ldap.searchUserName = "techadmin";
    ldap.tls = false;
    seedPath = ./portunus.json;
  };
}
