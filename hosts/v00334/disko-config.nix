{
  disko.devices = {
    disk.nixos = {
      type = "disk";
      device = "/dev/nvme0n1";
      content.type = "gpt";
      imageSize = "50G";  # Disk size when running as VM

      content.partitions.ESP = {
        type = "EF00";
        size = "550M";
        label = "BOOT";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          extraArgs = [ "-n" "BOOT" ];
          mountOptions = [
            "defaults"
          ];
        };
      };

      content.partitions.luks = {
        size = "100%";
        label = "CRYPT_NIXOS";

        content = {
          type = "luks";
          name = "crypt-nixos";
          settings = {
            allowDiscards = true;
            keyFileSize = 4096;
            keyFile = "/dev/disk/by-partlabel/CRYPTKEY";
            fallbackToPassword = true;
          };
        };

        content.content = {
          type = "btrfs";
          extraArgs = [ "-f" "-L" "NIXOS" ];

          postCreateHook = ''
            MNTPOINT=$(mktemp -d)
            mount -t btrfs "/dev/mapper/crypt-nixos" "$MNTPOINT"
            trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
            btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
          '';

          subvolumes = let
            mountOptions = [ "compress=zstd" "noatime" "ssd" "autodefrag" "discard=async" ];
          in {
            "root"     = { mountpoint = "/";        inherit mountOptions; };
            "nix"      = { mountpoint = "/nix";     inherit mountOptions; };
            "persist"  = { mountpoint = "/persist"; inherit mountOptions; };
            "log"      = { mountpoint = "/var/log"; inherit mountOptions; };
            "swap" = {
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

