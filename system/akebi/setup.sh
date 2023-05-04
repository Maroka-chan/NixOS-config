# Ask for the disk to install NixOS on
devices=($(lsblk -dno PATH))
device_count=${#devices[@]}
device_list=()

index=0
for device in ${devices[@]}; do
  device_list+=("${index}" "${device}")
  ((index++))
done

option=$(dialog --title "Select Device" --no-tags --menu "Select the device to install NixOS on" 0 0 "$device_count" "${device_list[@]}" 2>&1 >/dev/tty)

NIXOS_DISK=${devices[option]}

# Confirm disk wipe
dialog --title "WARNING - FORMAT DISK" --yesno "All data will be lost. Are you sure you want to wipe $NIXOS_DISK?" 6 35 || exit

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
sudo btrfs subvolume create /mnt/data

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
sudo mount -o subvol=data,compress=zstd,noatime,autodefrag "$ROOT_DISK" /mnt/data

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

# Generate NixOS config
echo "Generating NixOS config"
sudo nixos-generate-config --root /mnt

# Copy over and add the deployment user config
echo "Adding deployment user config"
sudo cp /etc/deployment-user.nix /mnt/etc/nixos/deployment-user.nix
sudo tee /mnt/etc/nixos/configuration.nix > /dev/null << EOF
    {config, pkgs, ...}:
    {
        imports = [
            ./deployment-user.nix
            ./hardware-configuration.nix
        ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        services.openssh.enable = true;

        system.stateVersion = "22.11";
    }
EOF

# Install NixOS
echo "Installing NixOS"
sudo nixos-install

# Persist files
echo "Persisting files"
PERSIST_DIR=/persist

sudo mkdir -p ${PERSIST_DIR}/etc/ssh

sudo cp {,$PERSIST_DIR}/etc/ssh/ssh_host_ed25519_key
sudo cp {,$PERSIST_DIR}/etc/ssh/ssh_host_ed25519_key.pub
sudo cp {,$PERSIST_DIR}/etc/machine-id

# Unmount
sudo umount -R /mnt

# Reboot
echo "Done! Rebooting.."
sleep 5
sudo reboot