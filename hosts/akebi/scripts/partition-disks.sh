echo "Choose which disk to install NixOS on:"
sudo lsblk -dno "PATH,SIZE"

while [ ! -b "$NIXOS_DISK" ]; do
    read -p "Disk: " NIXOS_DISK
done

# Maybe ask to choose drive(s) to use, and ask for raid level if multiple drives are chosen
# Also ask to skip if the drives are already set up as desired

# Confirm disk wipe
read -p "Are you sure you want to wipe $NIXOS_DISK? [y/N] " -r
[[ ! $REPLY =~ ^[Yy]$ ]] && exit

DATA_DISK_LABEL=DATA
DATA_DISK=/dev/disk/by-label/"$DATA_DISK_LABEL"

read -p "Which drives should be used for userdata? (separate with spaces) " -a RAID_DRIVES
if [ ${#RAID_DRIVES[@]} -gt 1 ]; then
    read -p "Which raid level should be used? [0/1/5/6/10] " RAID_LEVEL
elif [ ${#RAID_DRIVES[@]} -eq 0 ]; then
    echo "No drives selected."
    if [ ! -b "$DATA_DISK" ]; then
        echo "No DATA device found. Exiting."
        exit
    fi
fi

# Create partitions
# Creates a boot partition and a root partition
sudo sfdisk "$NIXOS_DISK" << EOF
label: gpt
size=550M, type=uefi
type=linux
EOF

# Create data partitions
sudo sfdisk "${RAID_DRIVES[@]}" << EOF
label: gpt
size=100%, type=linux
EOF

# Create Crypt passkey
echo "Creating encryption passkey for drives"
echo "Choose an external device for the encryption passkey:"
sudo lsblk -dno "PATH,SIZE"

while [ ! -b "$PASSKEY_DISK" ]; do
    read -p "Disk: " PASSKEY_DISK
done

# Confirm disk wipe
read -p "Are you sure you want to wipe $PASSKEY_DISK? [y/N] " -r
[[ ! $REPLY =~ ^[Yy]$ ]] && exit

#sudo mkfs.vfat -n CRYPTKEY "$PASSKEY_DISK"
PASSKEY_FILE=crypt.key
#PASSKEY_DISK=/dev/disk/by-label/CRYPTKEY

#sudo mkdir -p /media/cryptpasskey
#sudo mount "$PASSKEY_DISK" /media/cryptpasskey

sudo dd bs=1024 count=4 if=/dev/random of="$PASSKEY_FILE" iflag=fullblock
sudo chmod 600 "$PASSKEY_FILE"

sudo dd if="$PASSKEY_FILE" of="$PASSKEY_DISK"

# Create LUKS partitions for root
sudo cryptsetup -v -h sha512 -s 512 --iter-time 5000 luksFormat "$NIXOS_DISK"2 "$PASSKEY_FILE"
sudo cryptsetup luksHeaderBackup --header-backup-file "$NIXOS_DISK"2.luksheader "$NIXOS_DISK"2
sudo cryptsetup config "$NIXOS_DISK"2 --label CRYPT_NIXOS
sudo cryptsetup open --key-file="$PASSKEY_FILE" "$NIXOS_DISK"2 crypt-nixos
ROOT_DISK=/dev/mapper/crypt-nixos

# Create LUKS partitions for data
DATA_DRIVES=()
counter=0
for drive in "${RAID_DRIVES[@]}"; do
    sudo cryptsetup -v -h sha512 -s 512 --iter-time 5000 luksFormat "$drive" "$PASSKEY_FILE"
    sudo cryptsetup luksHeaderBackup --header-backup-file "$drive".luksheader "$drive"
    sudo cryptsetup config "$drive" --label CRYPT_DATA"$counter"
    sudo cryptsetup open --key-file="$PASSKEY_FILE" "$drive" crypt-data"$counter"
    #sudo mkfs.btrfs -L "$DATA_DISK_LABEL" /dev/mapper/crypt-data"$counter"
    DATA_DRIVES+=("/dev/mapper/crypt-data$counter")
    ((counter++))
done


# sudo cryptsetup --verify-passphrase -v luksFormat "$DATA_DISK"
# sudo cryptsetup config "$DATA_DISK" --label CRYPT_DATA
# sudo cryptsetup open "$DATA_DISK" crypt-data
# DATA_DISK=/dev/mapper/crypt-data

# Format partitions
echo "Formatting partitions"
sudo mkfs.vfat -n BOOT "$NIXOS_DISK"1
sudo mkfs.btrfs -L NIXOS "$ROOT_DISK"

# Create btrfs RAID array
if [ ${#RAID_DRIVES[@]} -gt 1 ]; then
    sudo mkfs.btrfs -L "$DATA_DISK_LABEL" -d raid$RAID_LEVEL -m raid$RAID_LEVEL "${DATA_DRIVES[@]}"
else
    sudo mkfs.btrfs -L "$DATA_DISK_LABEL" "${DATA_DRIVES[@]}"
fi
#sudo mkfs.btrfs -L "$DATA_DISK_LABEL" "$DATA_DISK"

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
sudo mount -o subvol=root,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt

sudo mkdir -p /mnt/{boot,swap,home,nix,persist,var/log,data}

sudo mount -o subvol=home,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt/home
sudo mount -o subvol=nix,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt/nix
sudo mount -o subvol=persist,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt/persist
sudo mount -o subvol=log,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt/var/log
sudo mount -o compress=zstd,noatime,autodefrag "$DATA_DISK" /mnt/data

# Set up swapfile
# btrfs filesystem mkswapfile --size 4G swapfile
echo "Setting up swapfile"
sudo mount -o subvol=swap "$ROOT_DISK" /mnt/swap
sudo truncate -s 0 /mnt/swap/swapfile
sudo chattr +C /mnt/swap/swapfile
sudo btrfs property set /mnt/swap/swapfile compression none
sudo dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=4096
sudo chmod 0600 /mnt/swap/swapfile
sudo mkswap -L SWAP /mnt/swap/swapfile

# As of btrfs-progs 6.1, it is possible to create the swapfile in a single command:
# btrfs filesystem mkswapfile --size 4g --uuid clear path/to/swapfile
#https://wiki.archlinux.org/title/Btrfs#Swap_file

sudo swapon /mnt/swap/swapfile

# Mount boot partition
echo "Mounting boot partition"
sudo mount "$NIXOS_DISK"1 /mnt/boot