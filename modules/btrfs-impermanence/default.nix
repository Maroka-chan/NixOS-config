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
      description = "Root partition to wipe on boot.";
    };
    blank-root = mkOption {
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

      btrfs subvolume list -o /mnt/root |
      cut -f9 -d' ' |
      while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "deleting /root subvolume..." &&
      btrfs subvolume delete /mnt/root

      echo "restoring blank /root subvolume..."
      btrfs subvolume snapshot /mnt/${cfg.blank-root} /mnt/root

      umount /mnt
    '';

    # Tools
    fs-diff = pkgs.writeScriptBin "fs-diff" ''
        set -euo pipefail

        OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/root-blank 9999999)

        sudo btrfs subvolume find-new "/mnt/root" "$OLD_TRANSID" |
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
      '';

    environment.systemPackages = with pkgs; [
        fs-diff
    ];
  };
}