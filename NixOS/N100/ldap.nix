{
  config,
  ragenix,
  my-secrets,
  ...
}:
{
  age.secrets.techadmin = {
    file = "${my-secrets}/homelab/techadmin.age";
    path = "/run/ragenix/homelab/techadmin";
    mode = "0400";
    owner = "nslcd";
    group = "nslcd";
  };

  users.ldap = {
    enable = true;
    useTLS = false;
    server = "ldap://192.168.10.17:389";
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
