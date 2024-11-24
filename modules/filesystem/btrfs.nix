{ lib, pkgs, config, username, ... }:
with lib;
let
  module_name = "btrfs";
  cfg = config.filesystem."${module_name}";
in {
  options.filesystem."${module_name}" = {
    enable = mkEnableOption "Set system up for BTRFS";

    impermanence = {
      enable = mkEnableOption "Wipe root and restore blank root BTRFS subvolume on boot.";
      root = mkOption {
        type = types.str;
        default = "/dev/mapper/crypt-nixos";
        description = "Encrypted root partition to mount.";
      };
      root-subvol = mkOption {
        type = types.str;
        default = "root";
        description = "Root subvolume to wipe on boot.";
      };
      blank-root-subvol = mkOption {
        type = types.str;
        default = "root-blank";
        description = "Blank root subvolume to restore on boot.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      boot.supportedFilesystems = [ "btrfs" ];
      services.btrfs.autoScrub.enable = true;
    })
    (mkIf cfg.impermanence.enable {
      # Wipe the root subvolume on boot.
      boot.initrd.postDeviceCommands = lib.mkBefore ''
        mkdir -p /mnt

        mount -t btrfs ${cfg.impermanence.root} /mnt

        btrfs subvolume list -o /mnt/${cfg.impermanence.root-subvol} |
        cut -f9 -d' ' |
        while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "deleting /${cfg.impermanence.root-subvol} subvolume..." &&
        btrfs subvolume delete /mnt/${cfg.impermanence.root-subvol}

        echo "restoring blank /${cfg.impermanence.root-subvol} subvolume..."
        btrfs subvolume snapshot /mnt/${cfg.impermanence.blank-root-subvol} /mnt/${cfg.impermanence.root-subvol}

        umount /mnt
      '';

      # Create directories
      systemd.tmpfiles.rules = [
        "d /persist/home/${username} 0700 ${username} users"
        # We need to explicitly set ownership on the home directory when using impermanence.
        # Otherwise, it will be owned as root, and home-manager will fail.
        "d /home/${username} 0700 ${username} users"
      ];

      environment.persistence."/persist" = {
        directories = [
          "/var/lib/btrfs"
        ];
      };

      environment.systemPackages = 
      let
        # Tools
        fs-diff = pkgs.writeScriptBin "fs-diff" ''
            set -euo pipefail

            mkdir -p /mnt
            mount -t btrfs ${cfg.impermanence.root} /mnt

            OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/${cfg.impermanence.blank-root-subvol} 9999999)
            OLD_TRANSID=''${OLD_TRANSID#transid marker was }

            sudo btrfs subvolume find-new "/mnt/${cfg.impermanence.root-subvol}" "$OLD_TRANSID" |
            sed '$d' |
            cut -f17- -d' ' |
            sort |
            uniq |
            while read path; do
              path="/$path"
              if [ -L "$path" ]; then
                : # The path is a symbolic link, so is probably handled by NixOS already
              elif [ -d "$path" ]; then
                : # The path is a directory, ignore
              else
                echo "$path"
              fi
            done

            umount /mnt
          '';
      in [ fs-diff ];
    })
  ];
}

