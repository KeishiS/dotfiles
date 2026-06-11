{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./dns.nix
  ];
  networking.hostName = "NixOS-keishis-P14s";
  networking.networkmanager.wifi.macAddress = "random";

  services.libinput.enable = true; # enable touchpad support
  services.fwupd.enable = true; # enable farmware update. `fwupdmgr refresh / fwupdmgr update / fwupdmgr get-updates`
  services.fprintd.enable = true; # enable fingerprint reader

  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  hardware.keyboard.qmk.enable = true;

  environment.systemPackages = with pkgs; [
    remmina
  ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  system.stateVersion = "26.05";
}
