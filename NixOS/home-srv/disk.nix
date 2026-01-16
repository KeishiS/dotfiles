{
  disko.devices = {
    disk.disk1 = {
      type = "disk";
      device = "";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
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
          lvm = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    disk.disk2 = {
      type = "disk";
      device = "";
      content = {
        type = "gpt";
        partitions = {
          lvm = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "32G";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };
        root = {
          size = "100%FREE";
          content = {
            type = "luks";
            name = "unlocked";
            settings.allowDiscards = true;
            passwordFile = "";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
        };
      };
    };
  };
}
