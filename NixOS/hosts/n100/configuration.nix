{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nginx.nix
    ../../modules/services/kanidm-client
    ../../modules/services/nfs-client
  ];

  networking.hostName = "NixOS-sandi-N100";
  networking.hostFiles = [ ./hosts.local ];

  sandi.nfsClient = {
    enable = true;
    mounts.users = {
      mountPoint = "/users";
      remote = "192.168.10.17:/users";
    };
  };

  system.stateVersion = "25.11";
}
