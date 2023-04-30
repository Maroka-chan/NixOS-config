# NixOS-config

## Setting up the NixOS server

### Set up the filesystem

- Set up the paritions with labels.
- Format the NixOS partition as a btrfs filesystem.
- Create the btrfs subvolumes.
- Generate NixOS configuration.

### Persist files

Copy files that needs to be persisted to the `persist` subvolume.

```bash
bash <(curl -s https://raw.githubusercontent.com/Maroka-chan/NixOS-config/master/scripts/nixos/persist-files.sh)
```

Need to find a better way to do this.
nixos-generators may be able to automate most of the set up process.

### Edit the default Nix configuration

- Set the hostname.
- Declare the deploy user w/ SSH key.
- Define sudo rules to make the deploy user non-interactive.
- Enable SSH.
- Apply the configuration.

The first [deployment](#deployment) has to use the `boot` goal.

```bash
colmena apply boot
```

Lastly, the server needs to be rebooted for the configuration to take effect.

```bash
colmena exec reboot
```

## Deployment

### Start a shell with Colmena

```bash
nix-shell -E '{pkgs ? import <nixpkgs> {}}: let colmena = import (fetchTarball "https://github.com/zhaofengli/colmena/archive/master.tar.gz"); in  pkgs.mkShell { buildInputs = [ colmena ]; }'
```

### Apply the configuration

```bash
colmena apply
```

## Secrets

[pass](https://www.passwordstore.org/) is used on the deployment machine to manage secrets.

### Add secrets

```bash
pass insert <hierarchical name>
```

To add a user password, use the output of:

```bash
mkpasswd -m sha-512
```
