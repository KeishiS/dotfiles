# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [];

    initrd = {
      availableKernelModules = [
        "xhci_pci" "ahci" "usbhid"
        "usb_storage" "sd_mod"
      ];
      kernelModules = [
        "dm-snapshot" "vfat" "nls_cp437"
        "nls_iso8859-1" "usbhid" "amdgpu"
      ];

      services.lvm.enable = true;
      luks.yubikeySupport = true;
      luks.devices."root" = {
        device = "/dev/disk/by-uuid/7c9011ff-50fd-4277-8a45-71a6bcc7ff8e";
        preLVM = false;
        yubikey = {
          slot = 1;
          twoFactor = true;
          gracePeriod = 60;
          keyLength = 64;
          saltLength = 16;
          storage = {
            device = "/dev/disk/by-uuid/F871-3411";
            fsType = "vfat";
            path = "/crypt-storage/default";
          };
        };
      };
    };
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
  };
  environment.systemPackages = with pkgs; [
    rocmPackages.rocminfo
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b5b0c2b1-5fb4-4184-8288-9d776e99a86a";
      fsType = "ext4";
    };


  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F871-3411";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp9s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp8s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}