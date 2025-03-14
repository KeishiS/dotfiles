{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/76a087b8-d2fd-44aa-8436-f8507602894e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0507-01F7";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
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

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
