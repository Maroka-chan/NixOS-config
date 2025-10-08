{ ... }:
{
  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.wallpaper = ../../dotfiles/wallpapers/Veo_Wallpaper1.jpg;
  desktops.niri.extraConfig = ''
    output "eDP-1" {
        mode "1920x1080@60"
        scale 1
        transform "normal"
        position x=0 y=920
    }

    output "Lenovo Group Limited P27h-20 V90A9AKD" {
        mode "2560x1440@60.0"
        scale 1
        transform "normal"
        position x=1920 y=560
    }

    output "Lenovo Group Limited P27h-20 V90A9AL0" {
        mode "2560x1440@60.0"
        scale 1
        transform "90"
        position x=4480 y=0
    }
  '';
}
