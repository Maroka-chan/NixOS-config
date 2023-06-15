{ config, pkgs, ... }:
{
    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/NetworkManager"
        ];
        files = [
            "/etc/machine-id"
            "/etc/nix/id_rsa"
        ];
    };

    # Wipe the root subvolume on boot.
    boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
        mkdir -p /mnt

        mount -t btrfs /dev/mapper/crypt-nixos /mnt

        btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "deleting /root subvolume..." &&
        btrfs subvolume delete /mnt/root

        echo "restoring blank /root subvolume..."
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        umount /mnt
    '';
}