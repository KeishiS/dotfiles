{
  config,
  ragenix,
  my-secrets,
  ...
}:
{
  age.secrets = {
    techadmin = {
      file = "${my-secrets}/homelab/techadmin.age";
      path = "/run/ragenix/homelab/techadmin";
      mode = "0440";
      owner = "portunus";
      group = "nslcd";
    };

    keishis = {
      file = "${my-secrets}/homelab/keishis.age";
      path = "/run/ragenix/homelab/keishis";
      mode = "0440";
      owner = "portunus";
      group = "nslcd";
    };
  };

  services.portunus = {
    enable = true;
    domain = "sandi05.com";
    ldap.suffix = "dc=sandi05,dc=com";
    ldap.searchUserName = "techadmin";
    ldap.tls = false;

    seedPath = ./portunus.json;
  };

  users.ldap = {
    enable = true;
    useTLS = false;
    server = "ldap://127.0.0.1:389";
    base = "dc=sandi05,dc=com";
    daemon.enable = true;
    bind = {
      distinguishedName = "uid=techadmin,ou=users,dc=sandi05,dc=com";
      passwordFile = config.age.secrets."techadmin".path;
    };
    loginPam = true;
    nsswitch = true;
  };
}
