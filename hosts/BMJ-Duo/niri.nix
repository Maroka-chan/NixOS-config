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

    input {
        keyboard {
            xkb {
                layout "us,dk"
                options "grp:alt_caps_toggle"
            }
            repeat-delay 200
            repeat-rate 25

            // Enable numlock on startup, omitting this setting disables it.
            numlock
        }
        mouse {
            accel-speed -0.3
            accel-profile "flat"
        }
        touchpad {
            tap
            natural-scroll
            accel-speed 0.1
            scroll-factor 0.75

        }
        touch {
            map-to-output "DP-3"
        }
        focus-follows-mouse max-scroll-amount="0%"
    }
  '';
}
