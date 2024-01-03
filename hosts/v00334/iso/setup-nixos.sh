#!/usr/bin/env bash

hostname=V00334

root_disk=/dev/nvme0n1
boot_part="$root_disk"p1
root_part="$root_disk"p2
swap_size=4096  # In Mebibytes

sudo wipefs -a "$root_disk"

# Format Disk
sudo sfdisk "$root_disk" << EOF
label: gpt
size=550M, type=uefi
type=linux
EOF

# Create Filesystems
sudo mkfs.vfat -n BOOT "$boot_part"
sudo mkfs.btrfs -L NIXOS "$root_part"

# Mount Partitions
sudo mount -t btrfs "$root_part" /mnt

# Create BTRFS Subvolumes
sudo btrfs subvolume create /mnt/root
sudo btrfs subvolume create /mnt/nix
sudo btrfs subvolume create /mnt/persist
sudo btrfs subvolume create /mnt/log
sudo btrfs subvolume create /mnt/home

# Create Swap Subvolume
sudo btrfs subvolume create /mnt/swap

# Create a blank *readonly* snapshot of the root subvolume,
# which we will rollback to on every boot
echo "Creating Blank Root Snapshot..."
sudo btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

# Unmount Root Partition
sudo umount /mnt

# Mount Subvolumes
sudo mount -o subvol=root,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt

sudo mkdir -p /mnt/{boot,swap,home,nix,persist,var/log,data}

sudo mount -o subvol=home,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt/home
sudo mount -o subvol=nix,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt/nix
sudo mount -o subvol=persist,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt/persist
sudo mount -o subvol=log,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt/var/log


# Set Up Swapfile
# btrfs filesystem mkswapfile --size 4G swapfile
sudo mount -o subvol=swap "$root_part" /mnt/swap
sudo truncate -s 0 /mnt/swap/swapfile
sudo chattr +C /mnt/swap/swapfile
sudo btrfs property set /mnt/swap compression none
sudo dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count="$swap_size"
sudo chmod 0600 /mnt/swap/swapfile
sudo mkswap -L SWAP /mnt/swap/swapfile

# Swapon
sudo swapon /mnt/swap/swapfile

# Mount Boot Partition
echo "Mounting Boot Partition..."
sudo mount "$boot_part" /mnt/boot

echo "DONE."

echo "Configure any additional disks and run:"
echo "sudo nixos-install --flake flake-uri#name --no-root-passwd"
