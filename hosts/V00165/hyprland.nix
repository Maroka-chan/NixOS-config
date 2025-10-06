{ ... }:
{
  # Desktop Environment
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = ''
    monitorv2 {
      output = eDP-1
      mode = 1920x1080@60
      position = 0x920
    }

    monitorv2 {
      output = desc:Lenovo Group Limited P27h-20 V90A9AKD
      mode = preferred
      position = 1920x560
    }

    monitorv2 {
      output = desc:Lenovo Group Limited P27h-20 V90A9AL0
      mode = preferred
      transform = 1
      position = 4480x0
    }

    exec-once = swaybg -i ${../../dotfiles/wallpapers/Veo_Wallpaper1.jpg} -m fill
    exec-once = ags run --gtk 3
  '';
}
