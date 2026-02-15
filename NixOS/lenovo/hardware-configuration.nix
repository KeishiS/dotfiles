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
    ./disk.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "btrfs" ];
    # zfs.forceImportRoot = false;

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
      kernelModules = [ "vfat" ];
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # sudo zpool create pool0 raidz /dev/sda1 /dev/sdb1
  # sudo zfs create -o mountpoint=legacy pool0/nfs
  # fileSystems."/nfs" = {
  #   device = "pool0/nfs";
  #   fsType = "zfs";
  # };

  # fileSystems."/users" = {
  #   device = "pool0/Users";
  #   fsType = "zfs";
  # };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
