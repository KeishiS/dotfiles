{
  config,
  lib,
  modulesPath,
  pkgs,
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
    supportedFilesystems = [ "btrfs" ];

    initrd = {
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [
        "amdgpu"
        "vfat"
      ];
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
