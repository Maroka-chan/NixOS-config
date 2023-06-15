echo "Choose which disk to install NixOS on:"
sudo lsblk -dno "PATH,SIZE"

while [ ! -b "$NIXOS_DISK" ]; do
    read -p "Disk: " NIXOS_DISK
done

# Confirm disk wipe
read -p "Are you sure you want to wipe $NIXOS_DISK? [y/N] " -r
[[ ! $REPLY =~ ^[Yy]$ ]] && exit

# Create partitions
# Creates a boot partition and a root partition
sudo sfdisk "$NIXOS_DISK" << EOF
label: gpt
size=550M, type=uefi
type=linux
EOF

# Create LUKS partitions for root
sudo cryptsetup -v -h sha512 -s 512 --iter-time 5000 --verify-password luksFormat "$NIXOS_DISK"2
sudo cryptsetup luksHeaderBackup --header-backup-file "$NIXOS_DISK"2.luksheader "$NIXOS_DISK"2
sudo cryptsetup config "$NIXOS_DISK"2 --label CRYPT_NIXOS
sudo cryptsetup open "$NIXOS_DISK"2 crypt-nixos
ROOT_DISK=/dev/mapper/crypt-nixos

# Format partitions
echo "Formatting partitions"
sudo mkfs.vfat -n BOOT "$NIXOS_DISK"1
sudo mkfs.ext4 -L NIXOS "$ROOT_DISK"

# Mount partitions
echo "Mounting partitions"
sudo mount "$NIXOS_DISK"1 /mnt/boot
sudo mount "$ROOT_DISK" /mnt/nix

# Set up swapfile
echo "Setting up swapfile"
sudo dd if=/dev/zero of=/mnt/nix/swapfile bs=1M count=16k status=progress
sudo chmod 0600 /mnt/nix/swapfile
sudo mkswap -U clear /mnt/nix/swapfile
sudo swapon /mnt/nix/swapfile

# Generate NixOS Configuration
echo "Generating NixOS config"
sudo nixos-generate-config --root /mnt