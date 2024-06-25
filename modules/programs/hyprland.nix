{ config, pkgs, lib, username, inputs, ... }:
with lib;
let
  module_name = "hyprland";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable the Hyprland Wayland Compositor";
    extraConfig = mkOption {
      type = types.str;
      default = "";
    };
  };

  imports = [
    inputs.home-manager.nixosModule
    inputs.hyprland.nixosModules.default
  ];

  config = mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.hyprland.enable = true;

    home-manager.users.${username} = {
      imports = [inputs.hyprland.homeManagerModules.default ];

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        plugins = [
          inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
        ];
        extraConfig = cfg.extraConfig + ''
          input {
            kb_layout = us,dk
            kb_options = grp:alt_caps_toggle
            repeat_rate = 25
            repeat_delay = 200

            sensitivity = 0
            accel_profile = flat
          }

          cursor {
            no_warps = true
          }

          gestures {
            workspace_swipe = true
            workspace_swipe_create_new = false
          }
          
          misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
          }

          general {
            border_size = 0
            gaps_in = 0
            gaps_out = 0

            col.active_border = rgba(fffc7fff)
            col.inactive_border = rgba(595959ff)

            layout = dwindle
          }

          decoration {
            rounding = 0
            drop_shadow = false
            blur {
              enabled = true
            }
          }

          # Animations
          animation=workspaces,1,4,default
          animation=windows,1,4,default

          # Bindings
          $mainMod = SUPER

          bind = $mainMod SHIFT, Q, killactive
          bind = $mainMod, F, fullscreen
          bind = $mainMod, M, fullscreen, 1
          bind = $mainMod, D, exec, rofi -show drun
          bind = $mainMod, Return, exec, alacritty
          bind = $mainMod, V, togglefloating
          bind = $mainMod, B, exec, librewolf

          bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | swappy -f -

          # Move focus with mainMod + arrow keys
          bind = $mainMod, left, movefocus, l
          bind = $mainMod, right, movefocus, r
          bind = $mainMod, up, movefocus, u
          bind = $mainMod, down, movefocus, d

          # Move active window with arrow keys
          bind = $mainMod SHIFT, left, movewindow, l
          bind = $mainMod SHIFT, right, movewindow, r
          bind = $mainMod SHIFT, up, movewindow, u
          bind = $mainMod SHIFT, down, movewindow, d

          # Move/resize windows with mainMod + LMB/RMB and dragging
          bindm = $mainMod, mouse:272, movewindow
          bindm = $mainMod, mouse:273, resizewindow

          # to switch between windows in a floating workspace
          bind = SUPER,Tab,cyclenext,          # change focus to another window
          bind = SUPER,Tab,bringactivetotop,   # bring it to the top

          # Volume button that allows press and hold, volume limited to 100%
          binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
          binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
          bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

          # Brightness button that allows press and hold
          binde = , XF86MonBrightnessUp, exec, tee /sys/class/backlight/intel_backlight/brightness <<< $(($(cat /sys/class/backlight/intel_backlight/brightness) + 1000))
          binde = , XF86MonBrightnessDown, exec, tee /sys/class/backlight/intel_backlight/brightness <<< $(($(cat /sys/class/backlight/intel_backlight/brightness) - 1000))

          # Switch workspaces with mainMod + [0-9]
          bind = $mainMod, 1, split-workspace, 1
          bind = $mainMod, 2, split-workspace, 2
          bind = $mainMod, 3, split-workspace, 3
          bind = $mainMod, 4, split-workspace, 4
          bind = $mainMod, 5, split-workspace, 5
          bind = $mainMod, 6, split-workspace, 6
          bind = $mainMod, 7, split-workspace, 7
          bind = $mainMod, 8, split-workspace, 8
          bind = $mainMod, 9, split-workspace, 9
          bind = $mainMod, 0, split-workspace, 10

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          bind = $mainMod SHIFT, 1, split-movetoworkspace, 1
          bind = $mainMod SHIFT, 2, split-movetoworkspace, 2
          bind = $mainMod SHIFT, 3, split-movetoworkspace, 3
          bind = $mainMod SHIFT, 4, split-movetoworkspace, 4
          bind = $mainMod SHIFT, 5, split-movetoworkspace, 5
          bind = $mainMod SHIFT, 6, split-movetoworkspace, 6
          bind = $mainMod SHIFT, 7, split-movetoworkspace, 7
          bind = $mainMod SHIFT, 8, split-movetoworkspace, 8
          bind = $mainMod SHIFT, 9, split-movetoworkspace, 9
          bind = $mainMod SHIFT, 0, split-movetoworkspace, 10

          # Layer Rule
          layerrule = blur,gtk-layer-shell
        '';
      };
    };
  };
}

