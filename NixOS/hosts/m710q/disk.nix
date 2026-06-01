let
  deviceName = "/dev/nvme0n1";
  passFile = "/tmp/luks.key";
in
{
  disko.devices = {
    disk.disk1 = {
      type = "disk";
      device = deviceName;
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

          Swap = {
            size = "8G";
            type = "8200";
            content.type = "swap";
          };

          Root = {
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
    };
  };
}
