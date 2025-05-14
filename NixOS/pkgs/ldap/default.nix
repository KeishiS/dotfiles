{ config, ... }:
{
  sops.secrets.techadmin = {
    format = "binary";
    sopsFile = ../portunus/secrets/techadmin.enc;
    path = "/run/sops-nix/homelab/techadmin";
    mode = "0440";
    owner = "root";
    group = "nslcd";
  };

  users.ldap = {
    enable = true;
    useTLS = false;
    server = "ldap://nixos-sandi-lenovo:389";
    base = "dc=sandi05,dc=com";
    daemon.enable = true;
    bind = {
      distinguishedName = "uid=techadmin,ou=users,dc=sandi05,dc=com";
      passwordFile = config.sops.secrets.techadmin.path;
    };
    loginPam = true;
    nsswitch = true;
  };
}
