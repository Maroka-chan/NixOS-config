{ config, pkgs, ... }:
let 
    nixsetup = pkgs.writeScriptBin "nixsetup" (builtins.readFile ./setup.sh);
in
{
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";

    environment.etc."deployment-user.nix".source = ./deployment-user.nix;

    environment.systemPackages = with pkgs; [
        dialog
        nixsetup
    ];

    services.openssh.enable = true;
}