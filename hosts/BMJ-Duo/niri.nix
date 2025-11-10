{ ... }:
{
  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.wallpaper = ../../dotfiles/wallpapers/makima.png;
  desktops.niri.extraConfig = ''
    output "eDP-1" {
        scale 2
        transform "180"
        position x=0 y=0
    }

    output "DP-3" {
        scale 2
        position x=0 y=-900
    }

  '';
}
