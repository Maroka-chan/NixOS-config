{ config, pkgs, ... }:
let
  setup_script = ./. + "/scripts/setup-nixos.sh";
  nixsetup = pkgs.writeScriptBin "nixsetup" ''
    ${setup_script}
  '';
in
{
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  environment.systemPackages = with pkgs; [
    git
    newt
    nixsetup
  ];

  users.users."nixos".openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqzG8P89pW2HiMb7zfJgp22t968eHuOsheYEHtuhshl aisaka" ];
}
