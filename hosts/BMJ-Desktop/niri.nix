{ ... }:
{
  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.wallpaper = ../../dotfiles/wallpapers/makima.png;
  desktops.niri.extraConfig = ''
    output "PNP(AOC) AG241QG4 0x00000024" {
        mode "2560x1440@143.912"
        scale 1
        transform "normal"
        position x=0 y=0
    }

    output "Lenovo Group Limited LEN P27h-10 0x56573654" {
        mode "2560x1440@60.0"
        scale 1
        transform "normal"
        position x=2560 y=0
    }
  '';
}
