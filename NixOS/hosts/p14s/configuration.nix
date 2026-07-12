{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./dns.nix
  ];
  networking.hostName = "NixOS-keishis-P14s";
  networking.networkmanager.wifi.macAddress = "random";
  # Temporary: allow inbound TCP for local testing.
  networking.firewall.allowedTCPPorts = [
    1514
    1515
  ];

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

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    remmina
  ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  system.stateVersion = "26.05";
}
