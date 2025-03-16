{
  ...
}:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /export/archlinux  192.168.10.0/24(rw,async,all_squash,no_subtree_check)
      /export/users      192.168.10.0/24(rw,async,no_root_squash,no_subtree_check)
    '';
  };
  networking.firewall.allowedTCPPorts = [ 2049 ];

  fileSystems."/export/archlinux" = {
    device = "/nfs/archlinux";
    options = [ "bind" ];
  };

  fileSystems."/export/users" = {
    device = "/users";
    options = [ "bind" ];
  };
}
