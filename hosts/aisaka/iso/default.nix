{ config, pkgs, ... }:
let
    setup_script = ./. + "/setup.sh";
    nixsetup = pkgs.writeScriptBin "nixsetup" ''
        ${setup_script}
    '';
    nixinstall = pkgs.writeScriptBin "nixinstall" ''
        # Install NixOS
        echo "Installing NixOS"
        sudo nixos-install --no-root-passwd --flake "git+https://github.com/Maroka-chan/NixOS-config#aisaka"
    '';
in
{
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";

    environment.systemPackages = with pkgs; [
        git
        nixsetup
        nixinstall
    ];
}
