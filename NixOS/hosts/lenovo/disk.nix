let
  osDisk = "/dev/disk/by-id/nvme-eui.002538a901b5aa54";
  # dataDisk0 = "/dev/disk/by-id/usb-TM_D4_SSD_20251016154C-0:0";
  # dataDisk1 = "/dev/disk/by-id/usb-TM_D4_SSD_20251016154C-0:1";
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = osDisk;
      content = {
        type = "gpt";
        partitions.ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
            extraArgs = [
              "-n"
              "BOOT"
            ];
          };
        };
        partitions.Swap = {
          size = "16G";
          type = "8200";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };
        partitions.root = {
          size = "100%";
          type = "8300";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };

    /*
      disk.data0 = {
        type = "disk";
        device = dataDisk0;
        content = {
          type = "gpt";
          partitions.lvm = {
            size = "100%";
            type = "8E00";
            content = {
              type = "lvm_pv";
              vg = "nixstore";
            };
          };
        };
      };

      disk.data1 = {
        type = "disk";
        device = dataDisk1;
        content = {
          type = "gpt";
          partitions.lvm = {
            size = "100%";
            type = "8E00";
            content = {
              type = "lvm_pv";
              vg = "nixstore";
            };
          };
        };
      };

      lvm_vg.nixstore = {
        type = "lvm_vg";
        lvs.nix = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            mountOptions = [ "noatime" ];
          };
        };
      };
    */
  };
}
