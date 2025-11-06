{}:
{
  # Desktop Environment
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = ''
    monitorv2 {
      output = eDP-1
      mode = preferred
      transform = 2
      scale = 2
    }
    monitorv2 {
      output = DP-3
      mode = preferred
      position = auto-up
      scale = 2
    }

    exec-once = swaybg -i ${../../dotfiles/wallpapers/makima.png} -m fill
    exec-once = ags run --gtk 3
  '';
}
