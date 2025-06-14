{
  pkgs,
  # vscode-server,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./nfs.nix
    # ./jellyfin.nix
    ./keylytix.nix
    ../pkgs/portunus
    ../pkgs/ldap
    ../pkgs/netdata
    ../pkgs/keylytix
    ../pkgs/plex
    # ../pkgs/prometheus
    # ./ldap.nix
  ];

  networking.hostName = "NixOS-sandi-lenovo";
  networking.hostId = "938fc0bf"; # for zfs. generated by `head -c 8 /etc/machine-id`

  environment.systemPackages = with pkgs; [
    gptfdisk
    zfs
    libarchive # for bsdtar
  ];

  system.stateVersion = "24.11";
}
