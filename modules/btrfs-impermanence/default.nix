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
  };
}