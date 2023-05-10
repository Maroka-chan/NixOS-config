# NixOS-config

## Setting up the NixOS server

### Build the ISO

```bash
nix build .#akebi-iso
```

### Boot into the ISO on the server

Run the setup script.

```bash
nixsetup
```

The setup script will do the following:
- Set up partitions
- Encrypt the drive
- Set up the btrfs filesystem
- Persist files
- Fetch the #akebi flake with git and install NixOS

#NOTE The script will set up a predefined system without prompts and will need to be modified if the physical hardware or its configuration is changed.

After rebooting, the system will be ready to receive [deployments](#deploying).

### Persisting files


## Deploying

### Start a shell with Colmena

```bash
nix-shell -E '{pkgs ? import <nixpkgs> {}}: let colmena = import (fetchTarball "https://github.com/zhaofengli/colmena/archive/master.tar.gz"); in  pkgs.mkShell { buildInputs = [ colmena ]; }'
```

### Apply the configuration

```bash
colmena apply
```

## Setting up Secrets

[pass](https://www.passwordstore.org/) is used on the deployment machine to manage secrets.

### Add secrets

```bash
pass insert <hierarchical name>
```

To add a user password, use the output of:

```bash
mkpasswd -m sha-512
```

## Testing the configuration in a VM

You can build and run the virtual machine specified in `flake.nix` to test the configuration.

Note: the hardware configuration and impermanence is not used with the VM.

```bash
nixos-rebuild build-vm --flake .#akebi-vm
./result/bin/run-akebi-vm
```

For a non-nixos system you will first need to start a shell with `nixos-rebuild`.

```bash
nix-shell -p nixos-rebuild
```
