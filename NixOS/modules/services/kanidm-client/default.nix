{ pkgs, ... }:
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
      sshIntegration = true;
      settings = {
        hsm_type = "tpm_if_possible";
        kanidm.pam_allowed_login_groups = [ "server-users" ];
        home_prefix = "/users/";
        home_mount_prefix = "/users";
        home_attr = "uuid";
        home_alias = "name";
        uid_attr_map = "name";
        gid_attr_map = "name";
      };
    };
  };

  # Home directories are provided by the shared /users NFS mount. Clients should
  # not create or manage those directories locally.
  systemd.services.kanidm-unixd-tasks.enable = false;
}
