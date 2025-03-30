# EDot - Edit Dotfiles
# Normally, apps such as Hyprland will immediatly reflect changes to its config.
# When using Nix to manage the config without impure methods, the file will be readonly.
# This script allows making live updates to the readonly dotfiles by temporarily substituting the file.
# Upon exiting the editor, the changes will be printed as a diff, which can then manually be applied to your Nix config.
{ pkgs, ... }: {
  environment.systemPackages = [(pkgs.writeShellApplication {
    name = "edot";
    text = ''
      orig=$(readlink "$1")
      sed -i ';' "$1" && chmod +w "$1"
      "$EDITOR" "$1"
      diff "$orig" "$1" --color || [ $? -eq 1 ]
      ln -sf "$orig" "$1"
    '';
  })];
}
