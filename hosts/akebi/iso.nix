{ config, pkgs, ... }:
let
    partition_script = ./. + "/scripts/partition-disks.sh";
    persist_script = ./. + "/scripts/persist-files.sh";
    nixsetup = pkgs.writeScriptBin "nixsetup" ''
        ${partition_script}

        # Generate NixOS config
        # echo "Generating NixOS config"
        # sudo nixos-generate-config --root /mnt

        # Install NixOS
        echo "Installing NixOS"
        sudo nixos-install --flake "git+https://github.com/Maroka-chan/NixOS-config?ref=filesystem/btrfs#akebi" --no-root-passwd

        # ${persist_script}
    '';
in
{
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";

    environment.systemPackages = with pkgs; [
        git
        nixsetup
    ];
}