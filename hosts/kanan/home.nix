{ config, pkgs, inputs, username, ...}:
let
  homeDirectory = "/home/${username}";
  dotfiles = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles";
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    pavucontrol # Audio control gui
    
    # Media players
    jellyfin-media-player
    mpv

    feh # Image Viewer

    cava # Audio Visualizer

    sioyek    # Document Viewer
    swaybg    # Wallpaper Tool
    swayidle  # Idle management
    hyprpicker

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
    inkscape

    inputs.neovim.packages.${pkgs.system}.default
    inputs.tlock.packages.${pkgs.system}.default
  ];

  programs.ags = {
    enable = true;
    configDir = "${dotfiles}/config/ags";
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };

  programs.obs-studio = {
    enable = true;
  };

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
        path = "/persist" + homeDirectory + "/.local/share/zsh/.zsh_history";
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
          { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; }
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
  home.persistence."/persist${homeDirectory}" = {
    allowOther = true;
    files = [
      ".p10k.zsh"
      ".cache/gitstatus/gitstatusd-linux-x86_64"
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
      ".zplug"
      ".local/share/Jellyfin Media Player/QtWebEngine/Default/Local Storage/leveldb"
      ".config/vesktop/sessionData/Local Storage/leveldb"
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".local/share/osu"
      ".local/share/password-store"
      ".thunderbird"
      ".config/protonmail/bridge-v3"
      ".local/share/protonmail/bridge-v3"
      ".local/share/DaVinciResolve"
      ".local/share/bottles"
      ".local/share/tlock"
      ".local/state/wireplumber"
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
    "thunar-volman-settings" = {
      name = "Removable Drives and Media";
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

