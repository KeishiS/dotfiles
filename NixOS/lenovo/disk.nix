let
  d0 = "<device0>";
  d1 = "<device1>";
  d2 = "<device2>";
  d3 = "<device3>";
in
{
  disko.devices = {
    disk.disk1 = {
      type = "disk";
      device = d1;
      content = {
        type = "gpt";
        partitions.data.size = "100%";
      };
    };

    disk.disk2 = {
      type = "disk";
      device = d2;
      content = {
        type = "gpt";
        partitions.data.size = "100%";
      };
    };

    disk.disk3 = {
      type = "disk";
      device = d3;
      content = {
        type = "gpt";
        partitions.data.size = "100%";
      };
    };

    disk.disk0 = {
      type = "disk";
      device = d0;
      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "-f"
              "-L NAS"
              "-d raid10"
              "-m raid1c3"
              d1
              d2
              d3
            ];

            subvolumes = {
              "/storage" = {
                mountpoint = "/storage";
                mountOptions = [
                  "noatime"
                  "ssd"
                  "space_cache=v2"
                  # "degraded"
                ];
              };
              "/pg" = {
                mountpoint = "/pg";
                mountOptions = [
                  "noatime"
                  "ssd"
                  "space_cache=v2"
                  # "degraded"
                ];
              };
            };
          };
        };
      };
    };
  };
}
