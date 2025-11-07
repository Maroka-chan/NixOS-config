{ pkgs, ... }:
pkgs.mkShell {
  packages = [ pkgs.deploy-rs ];
}
