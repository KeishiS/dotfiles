{ config, pkgs, ... }:
let
  domain = "id.sandi05.com";
in
{
  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_10;
    client = {
      enable = true;
      settings = {
        uri = "https://${domain}";
      };
    };
    unix = {
      enable = true;
      settings = {
        kanidm.pam_allowed_login_groups = [ "server-users" ];
        home_prefix = "/users/";
        home_attr = "name";
        home_alias = "none";
        uid_attr_map = "name";
        gid_attr_map = "name";
      };
    };
  };

  users.groups.kanidm-authorized-keys = { };
  users.users.kanidm-authorized-keys = {
    description = "Kanidm authorized keys delegate";
    isSystemUser = true;
    group = "kanidm-authorized-keys";
  };

  services.openssh.settings = {
    AuthorizedKeysCommand = "${config.security.wrapperDir}/kanidm_ssh_authorizedkeys %u";
    AuthorizedKeysCommandUser = "kanidm-authorized-keys";
  };

  security.wrappers.kanidm_ssh_authorizedkeys = {
    owner = "root";
    group = "root";
    permissions = "a+rx";
    source = "${config.services.kanidm.package}/bin/kanidm_ssh_authorizedkeys";
  };

  # Home directories are provided by the shared /users NFS mount. Clients should
  # not create or manage those directories locally.
  systemd.services.kanidm-unixd-tasks.enable = false;
}
