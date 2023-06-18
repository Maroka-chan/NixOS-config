#!/usr/bin/env bash

HOSTNAME=aisaka
MEMORY=2048

if [ ! -f backing.qcow2 ]; then
    qemu-img create -f qcow2 backing.qcow2 10G

    nix build ../../#"$HOSTNAME"-iso

    qemu-system-x86_64                                          \
    -enable-kvm                                                 \
    -m "$MEMORY"                                                \
    -hda backing.qcow2                                          \
    -bios /usr/share/OVMF/x64/OVMF.fd                           \
    -enable-kvm                                                 \
    -cdrom result/iso/nixos-*.iso
fi

trap "rm -f "$HOSTNAME".qcow2" EXIT

qemu-img create -f qcow2 -F qcow2 -b backing.qcow2 "$HOSTNAME".qcow2


# Start the VM
qemu-system-x86_64                                              \
    -enable-kvm                                                 \
    -m "$MEMORY"                                                \
    -hda "$HOSTNAME".qcow2                                      \
    -bios /usr/share/OVMF/x64/OVMF.fd                           \
    -enable-kvm