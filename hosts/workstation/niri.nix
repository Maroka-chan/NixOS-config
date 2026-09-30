{...}: {
  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.githubUsername = "AlexBMJ";
  desktops.niri.avatarHash = "sha256-S7mpUOUJ9lshVShSeqLImLGryVUzrWHjQUpE3buTSnk=";
  desktops.niri.wallpaper = ../../dotfiles/wallpapers/Veo_Wallpaper1.jpg;
  desktops.niri.extraConfig = ''
    output "Lenovo Group Limited P27h-20 V90A9AKD" {
        mode "2560x1440@60.0"
        scale 1
        transform "normal"
        position x=0 y=560
    }

    output "Lenovo Group Limited P27h-20 V90A9AL0" {
        mode "2560x1440@60.0"
        scale 1
        transform "90"
        position x=2560 y=0
    }
  '';

  # NVIDIA: stop the driver from holding on to freed VRAM in niri (can grow to GBs)
  # https://github.com/YaLTeR/niri/wiki/Nvidia
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text = builtins.toJSON {
    rules = [
      {
        pattern = {
          feature = "procname";
          matches = "niri";
        };
        profile = "Limit Free Buffer Pool On Wayland Compositors";
      }
    ];
    profiles = [
      {
        name = "Limit Free Buffer Pool On Wayland Compositors";
        settings = [
          {
            key = "GLVidHeapReuseRatio";
            value = 0;
          }
        ];
      }
    ];
  };
}
