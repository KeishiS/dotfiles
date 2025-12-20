{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];
  networking.hostName = "NixOS-keishis-P14s";

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

  system.stateVersion = "25.11";
}
