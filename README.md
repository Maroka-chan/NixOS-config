# NixOS-config

# Install on a new machine

1. Add new nixosConfiguration for the new machine and set up [secrets](#setting-up-secrets)
2. Add your public ssh key to [iso.nix](https://github.com/Maroka-chan/NixOS-config/blob/master/iso.nix) and boot into the installer iso on the target machine
```bash
nix build .#installer-iso --no-link --print-out-paths
```
3. Get hardware-configuration and devices from the target machine and adjust disko-config
```bash
ssh nixos@<ip> 'nixos-generate-config --no-filesystems --dir /mnt && cat /mnt/hardware-configuration.nix'
ssh nixos@<ip> 'lsblk'
```
4. Generate and *backup* keyfile
```bash
KEYPATH=$(mktemp)
dd bs=1024 count=4 if=/dev/random of="$KEYPATH" iflag=fullblock
chmod 0400 "$KEYPATH"
```
5. Write the keyfile to a USB. Simply plug it in and run:
```bash
./utils/create_keypart.sh "$KEYPATH"
```
6. Adjust and run the following command to install a nixosConfiguration on the target machine
```bash
nix run github:nix-community/nixos-anywhere -- \
    --disk-encryption-keys /dev/disk/by-partlabel/CRYPTKEY "$KEYPATH" \
    --flake .#<nixosConfiguration> nixos@<ip>
```
7. After reboot, backup LUKS header(s) from the target machine
```bash
ssh nixos@<ip>
sudo cryptsetup luksHeaderBackup --header-backup-file ./"$(hostname)".luksheader <crypt-partition>
```
8. Insert USB with key into the target machine so it can decrypt disks on reboot

# Test installing in interactive VM

1. Change device in disko-config to /dev/vda
2. Run `./utils/setup-vm.sh <nixosConfiguration>`

Example: `./utils/setup-vm.sh kanan`

We can also do a non-interactive VM test:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#<nixosConfiguration> --vm-test
```

# Deploying

1. Install [deploy-rs](https://github.com/serokell/deploy-rs)
2. Apply the configuration

```bash
deploy .#<deployNode>
```

# Setting up Secrets

I use [sops-nix](https://github.com/Mic92/sops-nix).

1. Generate age key
```bash
mkdir -p ~/.config/sops/age
nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"
```
2. Add secrets
```bash
nix-shell -p sops --run "sops hosts/<hostname>/secrets/secrets.yaml"
```

> :warning: To add a user password, use the sha hash given by executing:
```bash
mkpasswd -m sha-512
```
