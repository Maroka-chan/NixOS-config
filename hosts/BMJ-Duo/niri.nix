{...}: {
  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.avatarHash = "sha256-S7mpUOUJ9lshVShSeqLImLGryVUzrWHjQUpE3buTSnk=";
  desktops.niri.wallpaper = ../../dotfiles/wallpapers/makima.png;
  desktops.niri.extraConfig = ''
    output "eDP-1" {
        scale 2
        position x=0 y=0
    }

    output "DP-3" {
        scale 2
        position x=0 y=-900
    }

  '';
}
