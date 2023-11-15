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
sudo cryptsetup -v -h sha512 -s 512 --iter-time 20000 --verify-passphrase luksFormat "$NIXOS_DISK"2
# TODO: Also add keyfile before backing up luksHeader
#sudo cryptsetup -v -h sha512 -s 512 --iter-time 5000 luksFormat "$NIXOS_DISK"2 /key/aisaka-crypt.key
sudo cryptsetup config "$NIXOS_DISK"2 --label CRYPT_NIXOS
sudo cryptsetup luksHeaderBackup --header-backup-file aisaka-nixos.luksheader "$NIXOS_DISK"2
sudo cryptsetup open "$NIXOS_DISK"2 crypt-nixos
ROOT_DISK=/dev/mapper/crypt-nixos

# Format partitions
echo "Formatting partitions"
sudo mkfs.vfat -n BOOT "$NIXOS_DISK"1
sudo mkfs.btrfs -L NIXOS "$ROOT_DISK"

# Mount partitions
echo "Mounting partitions"
sudo mount -t btrfs "$ROOT_DISK" /mnt

# Create subvolumes
echo "Creating subvolumes"
sudo btrfs subvolume create /mnt/root
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

sudo mkdir -p /mnt/{boot,swap,nix,persist,var/log}

sudo mount -o subvol=nix,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt/nix
sudo mount -o subvol=persist,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt/persist
sudo mount -o subvol=log,compress=zstd,noatime,ssd,autodefrag,discard=async "$ROOT_DISK" /mnt/var/log


# Set up swapfile
echo "Setting up swapfile"
sudo mount -o subvol=swap "$ROOT_DISK" /mnt/swap
sudo truncate -s 0 /mnt/swap/swapfile
sudo chattr +C /mnt/swap/swapfile
sudo dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=4096
sudo chmod 0600 /mnt/swap/swapfile
sudo mkswap -L SWAP /mnt/swap/swapfile

sudo swapon /mnt/swap/swapfile

# Mount boot partition
echo "Mounting boot partition"
sudo mount "$NIXOS_DISK"1 /mnt/boot

# Create Secrets
echo "Creating secrets"

SOPS_DIR=/mnt/persist/etc/nixos/secrets
SECRETS_FILE="$SOPS_DIR"/secrets.yaml
SOPS_KEYS="$SOPS_DIR"/keys.txt

sudo mkdir -p "$SOPS_DIR"

# Generate age key
echo "Generating age key"
sudo nix-shell -p age --run "age-keygen -o $SOPS_KEYS"

PUB_KEY=$(sudo nix-shell -p age --run "age-keygen -y $SOPS_KEYS")

# Generate Secrets File
echo "Generating secrets file"
sudo tee "$SECRETS_FILE" > /dev/null <<EOT
maroka-password: 
EOT

# Set Passwords
sudo nix-shell -p vim --run "vim $SECRETS_FILE"
KEYS=$(sudo nix-shell -p yq-go --run "yq '.[] | key' $SECRETS_FILE")

for KEY in $KEYS
do
    PASSWORD=$(sudo nix-shell -p yq-go --run "yq '.${KEY}' $SECRETS_FILE")
    PASSWORD=$(sudo nix-shell -p mkpasswd --run "mkpasswd -m sha-512 $PASSWORD")
    sudo nix-shell -p yq-go --run "yq -i '.${KEY} = \"${PASSWORD}\"' $SECRETS_FILE"
done

# Encrypt Secrets File
sudo nix-shell -p sops --run "sops --age $PUB_KEY -e -i $SECRETS_FILE"
