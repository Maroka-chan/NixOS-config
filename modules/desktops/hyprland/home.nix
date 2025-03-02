{ config, pkgs, lib, inputs, username, extraHyprConfig, useImpermanence, ... }:
let
  homeDirectory = "/home/${username}";
  dotfiles = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles";
  inherit (lib) mkMerge mkIf;
in
mkMerge [{
  home = { inherit username homeDirectory; };
  home.packages = with pkgs; [
    # Screenshot
    swappy
    grim
    slurp

    # Clipboard utilities
    # Needed to make Vim use global clipboard
    wl-clipboard

    pavucontrol # Audio control gui
    feh         # Image Viewer
    mpv         # Media Player
    sioyek    # Document Viewer

    material-design-icons # Icons

    youtube-music # Music
  ];

  # Terminal Emulator
  programs.wezterm.enable = true;
  programs.wezterm.enableZshIntegration = true;
  programs.wezterm.extraConfig = ''
    local config = wezterm.config_builder()

    config.window_background_opacity = 0.9
    config.color_scheme = 'alacritty'

    return config
  '';

  # GPG & Password Store
  programs.password-store.enable = true;
  programs.gpg.enable = true;
  services.pass-secret-service.enable = true;
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    extraConfig = ''
      allow-preset-passphrase
    '';
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.dracula-theme;
      name = "Dracula";
    };
    iconTheme = {
      package = pkgs.dracula-icon-theme;
      name = "Dracula";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # Idle Daemon
  services.hypridle.enable = true;
  services.hypridle.settings = {
    general = {
      after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
    };

    listener = [
      {
        timeout = 300;
        on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
      }
      {
        timeout = 360;
        on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };
  
  # Status Bar
  programs.ags = {
    enable = true;
    configDir = "${dotfiles}/config/ags_new";
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_6_0
      accountsservice
      inputs.ags.packages.${pkgs.system}.hyprland
    ];
  };

  # Lock Screen
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 5;
        hide_cursor = false;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 2;
          blur_size = 2;
        }
      ];

      label = {
          monitor = "";
          text = "           へ            ╱|<br/>૮  -   ՛ )  ♡   (`   -  7.  <br/>/   ⁻  ៸|         |、⁻〵<br/>乀 (ˍ, ل ل         じしˍ,)ノ";
          text_align = "center";
          color = "rgba(243, 241, 141, 1.0)";
          font_size = 12;
          font_family = "Noto Sans";
          rotate = 0; # degrees, counter-clockwise

          position = "0, 80";
          halign = "center";
          valign = "center";
      };

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 2;
          placeholder_text = "Password...";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    package = null;
    portalPackage = null;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];
    extraConfig = extraHyprConfig + ''
      input {
        kb_layout = us,dk
        kb_options = grp:alt_caps_toggle
        repeat_rate = 25
        repeat_delay = 200

        sensitivity = -0.3
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
        shadow {
          enabled = false
        }
        blur {
          enabled = true
        }
      }

      # Animations
      animations {
        enabled = false
      }
      #animation=workspaces,0,4,default
      #animation=windows,1,4,default
      #animation = fade, 0

      # Bindings
      $mainMod = SUPER

      bind = $mainMod, TAB, exec, ${inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.io}/bin/astal -t bar

      bind = $mainMod SHIFT, Q, killactive
      bind = $mainMod, F, fullscreen
      bind = $mainMod, M, fullscreen, 1
      bind = $mainMod, D, exec, rofi -show drun
      bind = $mainMod, Return, exec, wezterm
      bind = $mainMod, V, togglefloating
      bind = $mainMod, B, exec, firefox

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


  #programs.walker.enable = true;
  programs.walker.theme = {
    layout = {
      "ui" = {
        "anchors" = {
          "bottom" = true;
          "left" = true;
          "right" = true;
          "top" = true;
        };
        "window" = {
          "box" = {
            "ai_scroll" = {
              "h_align" = "fill";
              "height" = 300;
              "list" = {
                "item" = {
                  "h_align" = "fill";
                  "name" = "aiItem";
                  "v_align" = "fill";
                  "wrap" = true;
                  "x_align" = 0;
                  "y_align" = 0;
                };
                "name" = "aiList";
                "orientation" = "vertical";
                "spacing" = 10;
                "width" = 400;
              };
              "margins" = {
                "top" = 8;
              };
              "max_height" = 300;
              "min_width" = 400;
              "name" = "aiScroll";
              "v_align" = "fill";
              "width" = 400;
            };
            "bar" = {
              "entry" = {
                "h_align" = "fill";
                "h_expand" = true;
                "icon" = {
                  "h_align" = "center";
                  "h_expand" = true;
                  "pixel_size" = 24;
                  "theme" = "Papirus";
                };
              };
              "orientation" = "horizontal";
              "position" = "end";
            };
            "h_align" = "center";
            "margins" = {
              "top" = 200;
            };
            "scroll" = {
              "list" = {
                "item" = {
                  "activation_label" = {
                    "h_align" = "fill";
                    "v_align" = "fill";
                    "width" = 20;
                    "x_align" = 0.5;
                    "y_align" = 0.5;
                  };
                  "icon" = {
                    "pixel_size" = 26;
                    "theme" = "Papirus";
                  };
                };
                "margins" = {
                  "top" = 8;
                };
                "max_height" = 300;
                "max_width" = 400;
                "min_width" = 400;
                "width" = 400;
              };
            };
            "search" = {
              "input" = {
                "h_align" = "fill";
                "h_expand" = true;
                "icons" = true;
              };
              "spinner" = {
                "hide" = true;
              };
            };
            "width" = 450;
          };
          "h_align" = "fill";
          "v_align" = "fill";
        };
      };
    };
    style = ''
      #window,
      #box,
      #search,
      #password,
      #input,
      #typeahead,
      #list,
      child,
      scrollbar,
      slider,
      #item,
      #text,
      #label,
      #bar,
      #sub,
      #activationlabel {
        all: unset;
      }

      #window {
        color: rgba(255, 255, 255, 0.8);
      }

      #box {
        border-radius: 2px;
        background: linear-gradient(
          to bottom,
          hsla(240, 12.7%, 13.9%, 0.98),
          hsla(219, 28.6%, 19.2%, 0.96)
        );
        padding: 32px;
        border: 1px solid #232d3f;
        box-shadow:
          0 19px 38px rgba(0, 0, 0, 0.3),
          0 15px 12px rgba(0, 0, 0, 0.22);
      }

      #search {
        box-shadow:
          0 1px 3px rgba(0, 0, 0, 0.1),
          0 1px 2px rgba(0, 0, 0, 0.22);
      }

      #prompt {
      }

      #password,
      #input,
      #typeahead {
        background: hsla(219, 28.6%, 19.2%, 0.8);
        padding: 8px;
        padding-top: 4px;
        padding-bottom: 4px;
        border-radius: 2px;
      }

      #input {
        background: none;
      }

      #password {
      }

      #spinner {
      }

      #typeahead {
        color: hsl(174, 89.7%, 32.7%);
      }

      #input placeholder {
      }

      #input > *:first-child,
      #typeahead > *:first-child {
        margin-right: 16px;
        margin-left: 4px;
        color: rgba(255, 255, 255, 0.8);
        opacity: 0.2;
      }

      #input > *:last-child,
      #typeahead > *:last-child {
        color: rgba(255, 255, 255, 0.8);
        opacity: 0.8;
      }

      #list {
      }

      child {
        padding: 9px;
        border-radius: 2px;
      }

      child:selected,
      child:hover {
        /*color: #232d3f;*/
        background: hsla(172, 100%, 25.3%, 0.6);
      }

      #item {
      }

      #icon {
        margin-right: 8px;
      }

      #text {
      }

      #label {
        font-weight: 500;
      }

      #sub {
        opacity: 0.5;
        font-size: 0.8em;
      }

      #activationlabel {
      }

      #bar {
      }

      .barentry {
      }

      .activation #activationlabel {
      }

      .activation #text,
      .activation #icon,
      .activation #search {
        opacity: 0.5;
      }
    '';
  };
}
(mkIf useImpermanence {
  home.persistence."/persist${homeDirectory}" = {
    allowOther = true;
    files = [
      ".pam-gnupg"
    ];
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "Music"
      ".ssh"
      ".dotfiles" # TODO: Fetch dotfiles with nix or add dotfiles to this repo
      ".zplug"
      ".local/state/wireplumber"
      ".local/share/password-store"
      ".config/protonmail/bridge-v3"
      ".local/share/protonmail/bridge-v3"
    ];
  };
})]
