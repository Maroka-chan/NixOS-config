#!/usr/bin/env bash

menu() { whiptail "$@" 3>&1 1>&2 2>&3 3>&- ; }
get_disks() { lsblk -ndo NAME,SIZE ; }

#################
#### Options ####
#################

# These are all set later on.
# Having them here is purely to give an,
# overview of the options used throughout the script.

# System
hostname=
swap_size=

# Root Disk
root_disk=
boot_part=
root_part=

# Root Encryption
encrypt_root=
root_crypt_use_keyfile=
root_crypt_use_passphrase=
root_crypt_label=
root_crypt_mapper_label=
header_path=
  


##################
#### Hostname ####
##################

while true; do
  hostname=$(menu --inputbox "Choose a Hostname" 0 0 --title "Hostname")
  [ $? -eq 1 ] && exit 0

  menu --title "Confirmation" --defaultno --yesno "This machines hostname will be '$hostname'. Is his correct?" 0 0
  [ $? -eq 0 ] && break
done



###################
#### Root Disk ####
###################

while true; do
  root_disk=$(menu --title "Root Disk" --menu "Choose root disk" 0 0 0 $(get_disks))
  [ $? -eq 1 ] && exit 0

  menu --title "Confirmation" --defaultno --yesno "All data on this disk will be lost. Are you sure?" 0 0
  [ $? -eq 0 ] && break
done

root_disk=/dev/"$root_disk"
boot_part="$root_disk"1
root_part="$root_disk"2


####################
#### Encryption ####
####################

while true; do
  menu --title "Encryption" --defaultno --yesno "Do you want to encrypt the root partition with cryptsetup?" 0 0
  [ $? -eq 1 ] && break

  menu --title "Confirmation" --yesno "Are you sure?" 0 0
  [ $? -eq 1 ] && break

  encrypt_root=0

  menu --title "Keyfile" --yesno "Should a keyfile be used for decryption?" 0 0
  root_crypt_use_keyfile=$?

  if [ $root_crypt_use_keyfile -eq 1 ]; then
    root_crypt_use_passphrase=0
  else
    menu --title "Keyfile" --yesno "Should a passphrase be added for decryption?" 0 0
    root_crypt_use_passphrase=$?
  fi
  
  root_crypt_label=CRYPT_NIXOS
  root_crypt_mapper_label=crypt-root

  break
done



# Give a summary before starting

# Format Root Disk
echo "Formatting Root Disk..."

sudo sfdisk "$root_disk" << EOF
label: gpt
size=550M, type=uefi
type=linux
EOF

# Encrypt Root Disk
if [ $encrypt_root -eq 0 ]; then

  if [ $root_crypt_use_keyfile -eq 0 ]; then
    while sudo [ ! -r "$key_path" ]; do
      menu --title "Add Crypt Key" --yesno "Do you already have a crypt key?" 0 0
      if [ $? -eq 1 ]; then
        echo "Generating Key..."

        key_path="$(sudo mktemp /tmp/${hostname}-crypt.key.XXXXXXXXXX)" || { echo "Failed to create temp key file"; exit 1; }

        sudo dd bs=1024 count=4 if=/dev/random of="$key_path" iflag=fullblock || { echo "Failed to Generate Crypt Key"; exit 1; }
        sudo chmod 0400 "$key_path"
      else
          key_path=$(menu --inputbox "Enter the path for the crypt key you want to add." 0 0 --title "Add Crypt Key")
      fi
    done
    echo "Encrypting Root Disk..."
    sudo cryptsetup -vq -h sha512 -s 512 --iter-time 5000 luksFormat "$root_part" "$key_path" || { echo "Failed to Encrypt Disk"; exit 1; }
  fi
  
  if [ $root_crypt_use_passphrase -eq 0 ]; then
    if [ $root_crypt_use_keyfile -eq 0 ]; then
      echo "Adding crypt password to Root Disk..."
      sudo cryptsetup luksAddKey --iter-time 20000 --verify-passphrase --key-file="$key_path" "$root_part" || { echo "Failed to Add Password to Root Disk"; exit 1; }
    else
      echo "Encrypting Root Disk..."
      sudo cryptsetup -vq -h sha512 -s 512 --iter-time 20000 --verify-passphrase luksFormat "$root_part" || { echo "Failed to Encrypt Disk"; exit 1; }
    fi
  fi

  sudo cryptsetup config "$root_part" --label "$root_crypt_label"
  header_path="$(sudo mktemp /tmp/${hostname}.luksheader.XXXXXXXXXX)" || { echo "Failed to create temp header file"; exit 1; }
  sudo cryptsetup luksHeaderBackup --header-backup-file "$header_path" "$root_part"

  if [ $root_crypt_use_keyfile -eq 0 ]; then
    sudo cryptsetup open "$root_part" "$root_crypt_mapper_label" --key-file "$key_path" || { echo "Failed to Decrypt Disk"; exit 1; }
  else
    sudo cryptsetup open "$root_part" "$root_crypt_mapper_label" || { echo "Failed to Decrypt Disk"; exit 1; }
  fi

  root_part=/dev/mapper/"$root_crypt_mapper_label"
fi

# Exit if any command fails
set -euo pipefail

echo "Creating Filesystems..."
sudo mkfs.vfat -n BOOT "$root_disk"1
sudo mkfs.btrfs -L NIXOS "$root_part"

echo "Mounting Partitions..."
sudo mount -t btrfs "$root_part" /mnt

echo "Creating Subvolumes..."
sudo btrfs subvolume create /mnt/root
sudo btrfs subvolume create /mnt/nix
sudo btrfs subvolume create /mnt/persist
sudo btrfs subvolume create /mnt/log

echo "Creating Swap Subvolume..."
sudo btrfs subvolume create /mnt/swap

# Create a blank *readonly* snapshot of the root subvolume,
# which we will rollback to on every boot
echo "Creating Blank Root Snapshot..."
sudo btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

echo "Unmounting Root Partition..."
sudo umount /mnt

echo "Mounting Subvolumes..."
sudo mount -o subvol=root,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt

sudo mkdir -p /mnt/{boot,swap,nix,persist,var/log}

sudo mount -o subvol=nix,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt/nix
sudo mount -o subvol=persist,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt/persist
sudo mount -o subvol=log,compress=zstd,noatime,ssd,autodefrag,discard=async "$root_part" /mnt/var/log


# Set up swapfile
# btrfs filesystem mkswapfile --size 4G swapfile
echo "Setting up swapfile..."
sudo mount -o subvol=swap "$root_part" /mnt/swap
sudo chmod 0700 /mnt/swap
sudo truncate -s 0 /mnt/swap/swapfile
sudo chattr +C /mnt/swap/swapfile

while true; do
  swap_size=$(menu --inputbox "How large should the swap space be? (In Mebibytes)." 0 0 --title "Add Swap Space" --nocancel)

  sudo dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count="$swap_size"
  [ $? -eq 0 ] && break
  echo "Invalid swap size."
done

sudo chmod 0600 /mnt/swap/swapfile
sudo mkswap -L SWAP /mnt/swap/swapfile

sudo swapon /mnt/swap/swapfile


echo "Mounting Boot Partition..."
sudo mount "$root_disk"1 /mnt/boot

echo "DONE."

echo "BACKUP YOUR CRYPT KEY AND HEADER!"
echo "$key_path"
echo "$header_path"

echo "Configure any additional disks and run:"
echo "sudo nixos-install --flake flake-uri#name --no-root-passwd"
