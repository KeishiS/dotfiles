{
  ...
}:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /export            192.168.10.0/24(rw,async,fsid=0,no_root_squash,no_subtree_check)
      /export/keylytix   192.168.10.0/24(rw,nohide,async,no_root_squash,no_subtree_check)
      /export/users      192.168.10.0/24(rw,nohide,async,no_root_squash,no_subtree_check)
    '';
  };
  networking.firewall.allowedTCPPorts = [ 2049 ];

  fileSystems."/export/keylytix" = {
    device = "/nfs/keylytix";
    options = [ "bind" ];
  };

  fileSystems."/export/users" = {
    device = "/users";
    options = [ "bind" ];
  };
}
