{
  disko.devices = {
    disk.nixos = {
      type = "disk";
      name = "CRYPT_NIXOS";
      device = "/dev/nvme0n1";
      imageSize = "20G";
      content.type = "gpt";

      content.partitions.ESP = {
        type = "EF00";
        size = "550M";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          extraArgs = [ "-n BOOT" ];
        };
      };

      content.partitions.luks = {
        size = "100%";

        content = {
          type = "luks";
          name = "crypt-nixos";
          settings = {
            allowDiscards = true;
            keyFileSize = 4096;
            keyFile = "/dev/disk/by-partlabel/CRYPTKEY";
          };
        };

        content.content = {
          type = "btrfs";
          extraArgs = [ "-f" "-L NIXOS" ];

          subvolumes = let
            mountOptions = [ "compress=zstd" "noatime" "ssd" "autodefrag" "discard=async" ];
          in {
            "/root"     = { mountpoint = "/";         mountOptions = [ "subvol=root" ]    ++ mountOptions; };
            "/home"     = { mountpoint = "/home";     mountOptions = [ "subvol=home" ]    ++ mountOptions; };
            "/nix"      = { mountpoint = "/nix";      mountOptions = [ "subvol=nix" ]     ++ mountOptions; };
            "/persist"  = { mountpoint = "/persist";  mountOptions = [ "subvol=persist" ] ++ mountOptions; };
            "/log"      = { mountpoint = "/var/log";  mountOptions = [ "subvol=log" ]     ++ mountOptions; };
            "/swap" = {
              mountpoint = "/swap";
              mountOptions = [ "subvol=swap" "noatime" ];
              swap.swapfile.size = "4G";
            };
          };

        };
      };

    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/swap".neededForBoot = true;
}
