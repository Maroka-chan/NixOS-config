#!/usr/bin/env bash

# nix-shell -p gptfdisk util-linux coreutils-full cryptsetup btrfs-progs newt

set -xe

### Options to set ###
hostname=kanan
root_disk=/dev/nvme0n1
swap_size=4096  # In Mebibytes
######################

boot_label=BOOT
root_label=NIXOS
boot_part=/dev/disk/by-partlabel/"$boot_label"
root_part=/dev/disk/by-partlabel/"$root_label"
root_crypt_label=CRYPT_"$root_label"
crypt_key_path=/dev/disk/by-partlabel/CRYPTKEY

# Format Disk
wipefs --all --force "$root_disk"
sgdisk \
  --new 1:0:+550M \
  --typecode 1:ef00 \
  --change-name 1:"$boot_label" \
  "$root_disk"
sgdisk \
  --new 2:0:0 \
  --typecode 2:8300 \
  --change-name 2:"$root_label" \
  "$root_disk"


# Generate Crypt Key
# Use existing key if usb already has CRYPTKEY partlabel
mount /dev/disk/by-partlabel/STORAGE /mnt
if [ ! -b "$crypt_key_path" ]; then
  cryptkey=./${hostname}-crypt.key
  dd bs=1024 count=4 if=/dev/random of="$cryptkey" iflag=fullblock
  ./create_keypart.sh "$cryptkey"
  install -m 0400 "$cryptkey" /mnt/
  rm "$cryptkey"
fi

sleep 1 # Wait for the partlabel to be created

# Encrypt Disk with Key
cryptsetup -vq -h sha512 -s 512 --iter-time 5000 luksFormat "$root_part" "$crypt_key_path"
cryptsetup config "$root_part" --label "$root_label"                                        # Set Label
cryptsetup open "$root_part" "$root_crypt_label" --key-file "$crypt_key_path"               # Decrypt Disk

# Backup LUKS Header
cryptsetup luksHeaderBackup --header-backup-file /mnt/${hostname}.luksheader "$root_part"
umount /mnt

root_part=/dev/mapper/"$root_crypt_label"

# Create Filesystems
mkfs.vfat -n "$boot_label" "$boot_part"
mkfs.btrfs -L "$root_label" "$root_part"

# Create BTRFS Subvolumes
mount -t btrfs "$root_part" /mnt
btrfs subvolume create /mnt/{root,home,nix,persist,log,swap}

# Create a blank *readonly* snapshot of the root subvolume,
# which we will rollback to on every boot
echo "Creating Blank Root Snapshot..."
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

umount /mnt

# Mount Subvolumes
mount_options=compress=zstd,noatime,ssd,autodefrag,discard=async
mount -o subvol=root,"$mount_options"     "$root_part"  /mnt
mkdir -p /mnt/{boot,swap,home,nix,persist,var/log,data}

mount -o subvol=home,"$mount_options"     "$root_part"  /mnt/home
mount -o subvol=nix,"$mount_options"      "$root_part"  /mnt/nix
mount -o subvol=persist,"$mount_options"  "$root_part"  /mnt/persist
mount -o subvol=log,"$mount_options"      "$root_part"  /mnt/var/log

# Set Up Swapfile
mount -o subvol=swap "$root_part" /mnt/swap
btrfs filesystem mkswapfile --size "$swap_size"m /mnt/swap/swapfile
swapon /mnt/swap/swapfile

# Mount Boot Partition
echo "Mounting Boot Partition..."
mount "$boot_part" /mnt/boot

echo "Configure any additional disks and run:"
echo "nixos-install --flake flake-uri#name --no-root-passwd"
