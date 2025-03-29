{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content.type = "gpt";
      imageSize = "50G"; # Disk size when running as VM

      content.partitions.ESP = {
        type = "EF00";
        size = "1G";
        label = "boot";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          extraArgs = [ "-n" "boot" ];
          mountOptions = [ "umask=0077" ];
        };
      };

      content.partitions.root = {
        size = "100%";
        label = "nixos";

        content = {
          type = "btrfs";
          extraArgs = [ "-f" "-L" "nixos" ];

          # Create snapshot regardless of if impermanence is enabled
          # This way we can enable impermanence later on if we want
          postCreateHook = ''
            MNTPOINT=$(mktemp -d)
            mount -t btrfs "/dev/disk/by-partlabel/nixos" "$MNTPOINT"
            trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
            btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
          '';

          subvolumes = let
            mountOptions = [ "compress=zstd" "noatime" "ssd" "autodefrag" "discard=async" ];
          in {
            "root"     = { mountpoint = "/";        inherit mountOptions; };
            "nix"      = { mountpoint = "/nix";     inherit mountOptions; };
            "log"      = { mountpoint = "/var/log"; inherit mountOptions; };
            "swap" = {
              mountpoint = "/swap";
              mountOptions = [ "subvol=swap" "noatime" ];
              swap.swapfile.size = "16G";
            };
          };
        };
      };
    };
  };

  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/swap".neededForBoot = true;
}
