{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nginx.nix
    ../../modules/services/kanidm-client
    ../../modules/services/nfs-client
  ];

  networking.hostName = "NixOS-sandi-N100";

  sandi.nfsClient = {
    enable = true;
    mounts.users = {
      mountPoint = "/users";
      remote = "calc-serv.sandi05.com:/users";
    };
  };

  system.stateVersion = "25.11";
}
