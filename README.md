<p align="center">
<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/ea1384e183f556a94df85c7aa1dcd411f5a69646/logo/nix-snowflake-colours.svg" alt="nix logo" width="100"/>
</p>

<h1 align="center">✨ Maroka's Config ✨</h1>

This config is intended for my own use and won't work for you out of the box. Feel free to use as inspiration ✨

# Install on a new machine

1. Add a nixosConfiguration for the new machine and set up [secrets](#setting-up-secrets).
2. Boot into the Nix minimal installer on the target machine and run `pass` so we can ssh to it.
3. Add a [Disko](hosts/kanan/disko-config.nix) config for the new machine.
4. Generate a hardware-configuration for the target machine.
```bash
# On target machine
nixos-generate-config --no-filesystems --show-hardware-config
```
5. Setup [disk encryption](#disk-encryption). (Optional)
6. Format and install the system with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).
```bash
# On source machine
nix run github:nix-community/nixos-anywhere -- \
    --disk-encryption-keys /dev/disk/by-partlabel/CRYPTKEY "$KEYPATH" \
    --flake .#<nixosConfiguration> nixos@<ip>
```

# Disk Encryption

This section generates a disk encryption key and writes it to a regular flash drive for decryption.
> Q. Why a regular flash drive?\
> A. I don't have a YubiKey :(

1. Generate and __backup__ keyfile.
```bash
# On source machine
KEYPATH=$(mktemp)
dd bs=1024 count=4 if=/dev/random of="$KEYPATH" iflag=fullblock
chmod 0400 "$KEYPATH"
```
2. Write the keyfile to a flash drive. Simply plug it in and run:
```bash
# On source machine
./utils/create_keypart.sh "$KEYPATH"
```

> :warning: Backup the LUKS header(s) after installation!
> ```bash
> # On target machine
> sudo cryptsetup luksHeaderBackup --header-backup-file ./"$(hostname)".luksheader <crypt-partition>
> ```

# Deploy

1. Run the devshell
```bash
nix develop
```
2. Apply the configuration

```bash
deploy .#<deployNode>
```

# Secrets

[Agenix](https://github.com/ryantm/agenix)

1. Generate SSH keypair or use system keys if OpenSSH is enabled.
```bash
ssh-keygen -t ed25519
```
2. Add secrets
```bash
nix run github:ryantm/agenix -- -e secret.age
```

> :warning: To add a user password, use the sha hash given by executing:
```bash
mkpasswd -m sha-512
```
