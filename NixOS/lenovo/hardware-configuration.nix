{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;

    initrd = {
      availableKernelModules = [
        "nvme"
        "ehci_pci"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b19cfa77-3f69-4bcf-babb-4cd34f686494";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0507-01F7";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  # sudo zpool create pool0 raidz /dev/sda1 /dev/sdb1
  # sudo zfs create -o mountpoint=legacy pool0/nfs
  fileSystems."/nfs" = {
    device = "pool0/nfs";
    fsType = "zfs";
  };

  fileSystems."/users" = {
    device = "pool0/Users";
    fsType = "zfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/fd106fd4-f475-4b91-981f-1af72098d527"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
