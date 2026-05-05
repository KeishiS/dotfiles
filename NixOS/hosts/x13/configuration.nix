{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "NixOS-keishis-X13";

  services.libinput.enable = true;
  environment.systemPackages = with pkgs; [
    mosh
  ];

  networking.firewall.allowedTCPPorts = [ 12121 ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
