{ lib, pkgs, config, ... }:
with lib;
let
  module_name = "btrfs-impermanence";
  cfg = config."${module_name}";
in {
  options."${module_name}" = {
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

  config = mkIf cfg.enable {
    # Wipe the root subvolume on boot.
    boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
      mkdir -p /mnt

      mount -t btrfs ${cfg.root} /mnt

      btrfs subvolume list -o /mnt/${cfg.root-subvol} |
      cut -f9 -d' ' |
      while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "deleting /${cfg.root-subvol} subvolume..." &&
      btrfs subvolume delete /mnt/${cfg.root-subvol}

      echo "restoring blank /${cfg.root-subvol} subvolume..."
      btrfs subvolume snapshot /mnt/${cfg.blank-root-subvol} /mnt/${cfg.root-subvol}

      umount /mnt
    '';

    environment.systemPackages = 
    let
      # Tools
      fs-diff = pkgs.writeScriptBin "fs-diff" ''
          set -euo pipefail

          mkdir -p /mnt
          mount -t btrfs ${cfg.root} /mnt

          OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/${cfg.blank-root-subvol} 9999999)
          OLD_TRANSID=''${OLD_TRANSID#transid marker was }

          sudo btrfs subvolume find-new "/mnt/${cfg.root-subvol}" "$OLD_TRANSID" |
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
    in
      with pkgs; [
        fs-diff
      ];
  };
}