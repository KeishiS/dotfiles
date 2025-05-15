{
  disko.device = {
    disk.main = {
      device = "/dev/nvme0n1";
      type = "disk";
      content.type = "gpt";
      content.partitions.BOOT = {
        size = "1G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };
      content.partitions.pv = {
        size = "100%";
        type = "8E00";
        content = {
          type = "lvm_pv";
          vg = "nixos";
        };
      };
    };

    lvm_vg.nixos = {
      type = "lvm_vg";
      lvs.swap = {
        size = "16G";
      };
      lvs.root = { };
    };
  };
}
