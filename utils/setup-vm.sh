#!/usr/bin/env bash

DISKSIZE=50G
MEMORY=4096

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT
qemu-img create -f qcow2 "$TMPDIR"/disk.img "$DISKSIZE"
qemu-system-x86_64 -enable-kvm \
    -m "$MEMORY" \
    -boot d -cdrom $(nix build .#installer-iso --no-link --print-out-paths)/iso/nixos-*.iso \
    -drive file="$TMPDIR"/disk.img,media=disk,if=virtio \
    -nic user,model=virtio,hostfwd=tcp::2222-:22 &

TMPKEY="$TMPDIR"/testkey
dd bs=1024 count=4 if=/dev/random of="$TMPKEY" iflag=fullblock

nix run github:nix-community/nixos-anywhere -- \
    --disk-encryption-keys /dev/disk/by-partlabel/CRYPTKEY "$TMPKEY" \
    --flake .#"$1" nixos@localhost -p 2222
