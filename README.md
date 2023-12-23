# NixOS-config

## Setting up the NixOS server

### Build the ISO

```bash
nix build .#akebi-iso
```

### Boot into the ISO on the server

Run the setup script (WIP).

```bash
./hosts/"<hostname>"/scripts/setup-nixos.sh
```

The setup script will do the following:
- Set up partitions
- Encrypt the drive
- Set up the btrfs filesystem

After rebooting, the system will be ready to receive [deployments](#deploying).

## Persisting files


## Deploying

### Install [deploy-rs](https://github.com/Mic92/sops-nix)

### Apply the configuration

```bash
deploy .#akebi
```

## Setting up Secrets

### Set up keys

[sops-nix](https://github.com/Mic92/sops-nix)

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

### Add secrets

```bash
nix-shell -p sops --run "sops hosts/<hostname>/secrets/secrets.yaml"
```

To add a user password, use the output of:

```bash
mkpasswd -m sha-512
```
