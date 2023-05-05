{ config, pkgs, ... }:
{
    # State to persist.
    environment.persistence."/persist" = {
        directories = [ ];
        files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
    };

    # Wipe the root subvolume on boot.
    boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
        mkdir -p /mnt

        mount -t btrfs /dev/mapper/enc /mnt

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