devices: { lib, ... }: {
  disko.devices.disk = lib.recursiveUpdate
    (builtins.foldl' (acc: idx: acc // { "data${toString idx}" = {
      type = "disk";
      device = builtins.elemAt devices (idx - 1);
      content = {
        type = "gpt";
        partitions."crypt_p${toString idx}" = {
          size = "100%";
          label = "CRYPT_DATA_${toString idx}";

          content = {
            type = "luks";
            name = "crypt-data-${toString idx}";
            settings = {
              allowDiscards = true;
              keyFileSize = 4096;
              keyFile = "/dev/disk/by-partlabel/CRYPTKEY";
              fallbackToPassword = true;
            };
          };
        };
      };
    }; }) {} (builtins.genList (n: n+1) (builtins.length devices)))
    {
      "data${toString (builtins.length devices)}".content.partitions."crypt_p${toString (builtins.length devices)}".content.content = {
        type = "btrfs";
        extraArgs = [
          "-L" "DATA"
          "-d" "raid1"
          "-m" "raid1"
        ]
        ++ builtins.map (x: "/dev/mapper/crypt-data-${toString x}") (builtins.genList (n: n+1) ((builtins.length devices) - 1));
        subvolumes = {
          "data" = {
            mountpoint = "/data";
            mountOptions = [ "compress=zstd" "noatime" "autodefrag" ];
          };
        };
      };
    };
}
