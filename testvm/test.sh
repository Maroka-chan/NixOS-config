#!/usr/bin/env bash

if [ ! -f backing.qcow2 ]; then
    qemu-img create -f qcow2 backing.qcow2 10G
    qemu-img create -f qcow2 akebi_data01.qcow2 1G
    qemu-img create -f qcow2 akebi_data02.qcow2 1G
    qemu-img create -f raw keyfile.raw 5M

    # if compgen -G "result/iso/nixos-*.iso" > /dev/null; then
    #     nix build .#akebi-iso
    # fi

    nix build .#akebi-iso

    qemu-system-x86_64                                          \
    -enable-kvm                                                 \
    -m 2048                                                     \
    -hda backing.qcow2                                          \
    -drive file=akebi_data01.qcow2,if=virtio                    \
    -drive file=akebi_data02.qcow2,if=virtio                    \
    -drive if=none,id=usbstick,format=raw,file=keyfile.raw      \
    -usb                                                        \
    -device usb-ehci,id=ehci                                    \
    -device usb-tablet,bus=usb-bus.0                            \
    -device usb-storage,bus=ehci.0,drive=usbstick               \
    -bios /usr/share/OVMF/x64/OVMF.fd                           \
    -enable-kvm                                                 \
    -cdrom result/iso/nixos-*.iso
fi

trap "rm -f akebi.qcow2" EXIT

qemu-img create -f qcow2 -F qcow2 -b backing.qcow2 akebi.qcow2


# Start the VM
qemu-system-x86_64                                              \
    -enable-kvm                                                 \
    -m 2048                                                     \
    -hda akebi.qcow2                                            \
    -drive file=akebi_data01.qcow2,if=virtio                    \
    -drive file=akebi_data02.qcow2,if=virtio                    \
    -drive if=none,id=usbstick,format=raw,file=keyfile.raw      \
    -usb                                                        \
    -device usb-ehci,id=ehci                                    \
    -device usb-tablet,bus=usb-bus.0                            \
    -device usb-storage,bus=ehci.0,drive=usbstick               \
    -bios /usr/share/OVMF/x64/OVMF.fd                           \
    -enable-kvm                                                 \
    -net nic                                                    \
    -net user,hostfwd=tcp::60022-:22,hostfwd=tcp::8096-:8096,hostfwd=tcp::9091-:9091