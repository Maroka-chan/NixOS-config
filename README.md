# NixOS-config

## Setting up a NixOS system

Make sure that the `$HOSTNAME` has been set correctly, and that the filesystem is set up properly.

1. Clone the repository to `$HOME`
2. Set user passwords that will persist

```bash
./scripts/nixos/set-password-secret.sh
```

3. Add other secrets

```bash
./scripts/nixos/modify-secrets.sh
```

4. Copy files that needs to be persistent from root to `/persist`

```bash
./scripts/nixos/persist-files.sh
```

5. Build the system and add it to the boot menu

```bash
sudo nixos-rebuild boot --flake ./system/$HOSTNAME
```

6. Reboot
