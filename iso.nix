{ ... }:
{
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  systemd.tmpfiles.rules = [ "d /dev/disk/by-partlabel 0755 root root" ];
  users.users."nixos".openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyMZKyptGPtS/osbdmDrhnn2J08Iiy/i+BrvqvyNBpJ kanan" ];
}
