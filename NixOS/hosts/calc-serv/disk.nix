let
  osDisk = "/dev/disk/by-id/nvme-KIOXIA-EXCERIA_PLUS_G4_SSD_1F7KS0PFZ23K"; # KIOXIA EXCERIA PLUS G4 1TB
  dataDisk0 = "/dev/disk/by-id/nvme-CT1000P3PSSD8_2330E86431EF"; # Crucial P3 Plus 1TB
  dataDisk1 = "/dev/disk/by-id/nvme-CT500P3PSSD8_2401463FE054"; # Crucial P3 Plus 500GB
  dataDisk2 = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_25373H800642"; # WD_BLACK SN850X 1TB
  dataDisk3 = "/dev/disk/by-id/nvme-WD_Red_SN700_1000GB_25463A801500"; # WD Red SN700 1TB
  dataDisk4 = "/dev/disk/by-id/wwn-0x500a0751e8a0a655"; # Crucial MX500 1TB
  dataDisk0Part = "${dataDisk0}-part1";
  dataDisk1Part = "${dataDisk1}-part1";
  dataDisk2Part = "${dataDisk2}-part1";
  dataDisk3Part = "${dataDisk3}-part1";
  passFile = "/tmp/luks.key";
in
{
  disko.devices = {
    # for OS
    disk.main = {
      type = "disk";
      device = osDisk;
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
            passwordFile = passFile;
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

    # for Data
    disk.data0 = {
      type = "disk";
      device = dataDisk0;
      content = {
        type = "gpt";
        partitions.data.size = "100%";
      };
    };

    disk.data1 = {
      type = "disk";
      device = dataDisk1;
      content = {
        type = "gpt";
        partitions.data.size = "100%";
      };
    };

    disk.data2 = {
      type = "disk";
      device = dataDisk2;
      content = {
        type = "gpt";
        partitions.data.size = "100%";
      };
    };

    disk.data3 = {
      type = "disk";
      device = dataDisk3;
      content = {
        type = "gpt";
        partitions.data.size = "100%";
      };
    };

    disk.data4 = {
      type = "disk";
      device = dataDisk4;
      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "-f"
              "-L"
              "NAS"
              "-d"
              "raid1c3"
              "-m"
              "raid1c3"
              dataDisk0Part
              dataDisk1Part
              dataDisk2Part
              dataDisk3Part
            ];

            subvolumes = {
              "/storage" = {
                mountpoint = "/storage";
                mountOptions = [
                  "noatime"
                  "compress=zstd:3"
                  "discard=async"
                  "space_cache=v2"
                ];
              };

              "/users" = {
                mountpoint = "/users";
                mountOptions = [
                  "noatime"
                  "compress=zstd:3"
                  "discard=async"
                  "space_cache=v2"
                ];
              };
            };
          };
        };
      };
    };
  };
}
