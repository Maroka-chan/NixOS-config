echo "Choose which disk to install NixOS on:"
sudo lsblk -dno "PATH,SIZE"

while [ ! -b "$NIXOS_DISK" ]; do
    read -p "Disk: " NIXOS_DISK
done

# Confirm disk wipe
read -p "Are you sure you want to wipe $NIXOS_DISK? [y/N] " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit

# Create partitions
# Creates a boot partition and a root partition
sudo sfdisk "$NIXOS_DISK" << EOF
label: gpt
size=550M, type=uefi
type=linux
EOF

# Create LUKS partitions
sudo cryptsetup --verify-passphrase -v luksFormat "$NIXOS_DISK"2
sudo cryptsetup config "$NIXOS_DISK"2 --label CRYPT_NIXOS
sudo cryptsetup open "$NIXOS_DISK"2 crypt-nixos
ROOT_DISK=/dev/mapper/crypt-nixos

# Format partitions
echo "Formatting partitions"
sudo mkfs.vfat -n BOOT "$NIXOS_DISK"1
sudo mkfs.btrfs -L NIXOS "$ROOT_DISK"

# Mount partitions
echo "Mounting root partition"
sudo mount -t btrfs "$ROOT_DISK" /mnt

# Create subvolumes
echo "Creating subvolumes"
sudo btrfs subvolume create /mnt/root
sudo btrfs subvolume create /mnt/home
sudo btrfs subvolume create /mnt/nix
sudo btrfs subvolume create /mnt/persist
sudo btrfs subvolume create /mnt/log

# Subvolume for swapfile
echo "Creating swap subvolume"
sudo btrfs subvolume create /mnt/swap

# Create a blank *readonly* snapshot of the root subvolume,
# which we will rollback to on every boot
echo "Creating blank root snapshot"
sudo btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

echo "Unmounting root partition"
sudo umount /mnt

# Mount subvolumes
echo "Mounting subvolumes"
sudo mount -o subvol=root,compress=zstd,noatime,ssd,autodefrag "$ROOT_DISK" /mnt

sudo mkdir -p /mnt/{boot,swap,home,nix,persist,var/log}

sudo mount -o subvol=home,compress=zstd,noatime,ssd,autodefrag "$ROOT_DISK" /mnt/home
sudo mount -o subvol=nix,compress=zstd,noatime,ssd,autodefrag "$ROOT_DISK" /mnt/nix
sudo mount -o subvol=persist,compress=zstd,noatime,ssd,autodefrag "$ROOT_DISK" /mnt/persist
sudo mount -o subvol=log,compress=zstd,noatime,ssd,autodefrag "$ROOT_DISK" /mnt/var/log

# Set up swapfile
echo "Setting up swapfile"
sudo mount -o subvol=swap "$ROOT_DISK" /mnt/swap
sudo truncate -s 0 /mnt/swap/swapfile
sudo chattr +C /mnt/swap/swapfile
sudo btrfs property set /mnt/swap/swapfile compression none
sudo dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=4096
sudo chmod 600 /mnt/swap/swapfile
sudo mkswap -L SWAP /mnt/swap/swapfile

# Mount boot partition
echo "Mounting boot partition"
sudo mount "$NIXOS_DISK"1 /mnt/boot