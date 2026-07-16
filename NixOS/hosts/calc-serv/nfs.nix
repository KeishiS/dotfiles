{ ... }:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /export            192.168.100.0/24(rw,fsid=0,crossmnt,sync,root_squash,no_subtree_check)
      /export/users      192.168.100.0/24(rw,sync,root_squash,no_subtree_check)
      /export/storage    192.168.100.0/24(rw,sync,root_squash,no_subtree_check)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];

  fileSystems = {
    "/export/users" = {
      device = "/users";
      fsType = "none";
      options = [ "bind" ];
    };

    "/export/storage" = {
      device = "/storage";
      fsType = "none";
      options = [ "bind" ];
    };
  };
}
