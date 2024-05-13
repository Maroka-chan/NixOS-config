{ config, pkgs, inputs, ...}:
let
  dotfiles = config.lib.file.mkOutOfStoreSymlink "/home/maroka/.dotfiles";
in
{
  home.packages = with pkgs; [
    pavucontrol # Audio control gui
    
    # Media players
    jellyfin-media-player
    mpv

    feh # Image Viewer

    cava # Audio Visualizer

    sioyek    # Document Viewer
    brave     # Browser
    swaybg    # Wallpaper Tool
    swayidle  # Idle management

    # Screenshot
    swappy
    grim
    slurp

    material-design-icons # Icons

    osu-lazer-bin

    sshfs     # Remote filesystems over SSH

    vesktop   # Third-party Discord

    davinci-resolve
    bottles
    blender-hip

    inputs.neovim.packages.${pkgs.system}.default
  ];

  programs = {
    alacritty = {
      enable = true;
    };
    thunderbird = {
      enable = true;
      settings = {
        "general.useragent.override" = "";
        "privacy.donottrackheader.enabled" = true;
      };
      profiles.main = {
        isDefault = true;
      };
    };
    password-store.enable = true;
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      extraConfig = {
        modi = "drun,run,filebrowser,window";
        show-icons = true;
        display-drun = "APPS";
        display-run = "RUN";
        display-filebrowser = "FILES";
        display-window = "WINDOW";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
      };
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          font = "JetBrains Mono Nerd Font 10";
          background = mkLiteral "#180F39";
          background-alt = mkLiteral "#32197D";
          foreground = mkLiteral "#FFFFFF";
          selected = mkLiteral "#FF00F1";
          active = mkLiteral "#9878FF";
          urgent = mkLiteral "#7D0075";
        };

        window = {
          transparency = "real";
          location = mkLiteral "center";
          anchor = mkLiteral "center";
          fullscreen = false;
          width = mkLiteral "1000px";
          x-offset = mkLiteral "0px";
          y-offset = mkLiteral "0px";
          enabled = true;
          border-radius = mkLiteral "15px";
          cursor = "default";
          background-color = mkLiteral "@background";
        };

        mainbox = {
          enabled = true;
          spacing = mkLiteral "0px";
          background-color = mkLiteral "transparent";
          orientation = mkLiteral "horizontal";
          children = [ "imagebox" "listbox" ];
        };

        imagebox = {
          padding = mkLiteral "20px";
          background-color = mkLiteral "transparent";
          background-image = mkLiteral ("url(" + "\"${dotfiles}/images/b.png\"" + ", height)");
          orientation = mkLiteral "vertical";
          children = [ "inputbar" "dummy" "mode-switcher" ];
        };

        listbox = {
          spacing = mkLiteral "20px";
          padding = mkLiteral "20px";
          background-color = mkLiteral "transparent";
          orientation = mkLiteral "vertical";
          children = [ "message" "listview" ];
        };

        dummy = {
          background-color = mkLiteral "transparent";
        };

        inputbar = {
          enabled = true;
          spacing = mkLiteral "10px";
          padding = mkLiteral "15px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@background-alt";
          text-color = mkLiteral "@foreground";
          children = [ "textbox-prompt-colon" "entry" ];
        };

        textbox-prompt-colon = {
          enabled = true;
          expand = false;
          str = "";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        entry = {
          enabled = true;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "text";
          placeholder = "Search";
          placeholder-color = mkLiteral "inherit";
        };

        mode-switcher = {
          enabled = true;
          spacing = mkLiteral "20px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
        };

        button = {
          padding = mkLiteral "15px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@background-alt";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "pointer";
        };

        "button selected" = {
          background-color = mkLiteral "@selected";
          text-color = mkLiteral "@foreground";
        };

        listview = {
          enabled = true;
          columns = 1;
          lines = 8;
          cycle = true;
          dynamic = true;
          scrollbar = false;
          layout = mkLiteral "vertical";
          reverse = false;
          fixed-height = true;
          fixed-columns = true;
          spacing = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
          cursor = "default";
        };

        element = {
          enabled = true;
          spacing = mkLiteral "15px";
          padding = mkLiteral "8px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
          cursor = mkLiteral "pointer";
        };
        "element normal.normal" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        "element normal.urgent" = {
          background-color = mkLiteral "@urgent";
          text-color = mkLiteral "@foreground";
        };
        "element normal.active" = {
          background-color = mkLiteral "@active";
          text-color = mkLiteral "@foreground";
        };
        "element selected.normal" = {
          background-color = mkLiteral "@selected";
          text-color = mkLiteral "@foreground";
        };
        "element selected.urgent" = {
          background-color = mkLiteral "@urgent";
          text-color = mkLiteral "@foreground";
        };
        "element selected.active" = {
          background-color = mkLiteral "@urgent";
          text-color = mkLiteral "@foreground";
        };
        element-icon = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          size = mkLiteral "32px";
          cursor = mkLiteral "inherit";
        };
        element-text = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        message = {
          background-color = mkLiteral "transparent";
        };

        textbox = {
          padding = mkLiteral "15px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@background-alt";
          text-color = mkLiteral "@foreground";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        error-message = {
          padding = mkLiteral "15px";
          border-radius = mkLiteral "20px";
          background-color = mkLiteral "@background";
          text-color = mkLiteral "@foreground";
        };
      };
    };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        path = "/persist/home/maroka/.local/share/zsh/.zsh_history";
      };

      initExtraFirst = ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

      '';

      initExtra = ''
        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';

      zplug = {
        enable = true;
        plugins = [
                { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
        ];
      };
    };
    git = {
      enable = true;
      userName = "Maroka-chan";
      userEmail = "64618598+Maroka-chan@users.noreply.github.com";
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    librewolf = {
      enable = true;
    };
    firefox = {
      enable = true;
    };
    swaylock = {
      enable = true;
    };
    gpg.enable = true;
   # hyprlock = {
   #   enable = true;
   #   backgrounds = [{
   #     path = "screenshot";
   #   }];
   #   input-fields = [{
   #     
   #   }];
   # };
  };

  # Home Manager Persistence
  home.persistence."/persist/home/maroka" = {
    allowOther = true;
    files = [
      ".p10k.zsh"
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/Mullvad VPN/gui_settings.json"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
      ".config/sops/age/keys.txt"
      ".config/vesktop/settings/settings.json"
      ".config/vesktop/settings.json"
      ".config/vesktop/state.json"
      ".pam-gnupg"
    ];
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "Music"
      ".ssh"
      ".dotfiles"
      ".config/BraveSoftware/Brave-Browser"
      ".librewolf"
      ".zplug"
      ".local/share/Jellyfin Media Player/QtWebEngine/Default/Local Storage/leveldb"
      ".config/vesktop/sessionData/Local Storage/leveldb"
      ".local/share/direnv/allow"
      ".config/github-copilot"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".local/share/osu"
      ".local/share/password-store"
      ".thunderbird"
      ".config/protonmail/bridge-v3"
      ".local/share/protonmail/bridge-v3"
      ".local/share/DaVinciResolve"
      ".local/share/bottles"
    ];
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

  services.pass-secret-service.enable = true;
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    extraConfig = ''
      allow-preset-passphrase
    '';
  };

  # Idle Daemon
  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"; }
      { timeout = 320; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
    ];
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      monitor=DP-3,2560x1440@240,1080x240,1
      monitor=HDMI-A-1,1920x1080@60,0x0,1,transform,3

      exec-once = swaybg -i ${dotfiles}/wallpapers/yume_no_kissaten_yumegatari.png -m fill
      exec-once = eww daemon & eww open-many statusbar radio controls

      windowrulev2 = idleinhibit fullscreen,class:(org.jellyfin.),title:(Jellyfin Media Player)

      input {
        kb_layout = us,dk
        kb_options = grp:alt_caps_toggle
        repeat_rate = 25
        repeat_delay = 200

        sensitivity = 0
        accel_profile = flat
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
        border_size = 2
        gaps_in = 1
        gaps_out = 2

        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)

        layout = dwindle
      }

      decoration {
        rounding = 2
        blur {
          enabled = true
        }
      }

      # Animations
      animation=workspaces,1,4,default

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
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Layer Rule
      layerrule = blur,gtk-layer-shell
    '';
  };

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/config/eww";
  
  # Alacritty
  xdg.configFile."alacritty".source = "${dotfiles}/config/alacritty";

  # Hide desktop files
  xdg.desktopEntries = {
    "thunar-bulk-rename" = {
      name = "Bulk Rename";
      noDisplay = true;
    };
    "thunar-settings" = {
      name = "File Manager Settings";
      noDisplay = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}

