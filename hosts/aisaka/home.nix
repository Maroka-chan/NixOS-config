{ config, pkgs, inputs, ...}:
let
  dotfiles = config.lib.file.mkOutOfStoreSymlink "/home/maroka/.dotfiles";
in
{
  home.packages = with pkgs; [
    alacritty # Terminal emulator
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

    sshfs       # Remote filesystems over SSH

    webcord   # Third-party Discord

    deploy-rs # Deployment Tool

    jetbrains.idea-ultimate # Intellij Java IDE
    jetbrains.rider         # Dotnet IDE

    inputs.neovim.packages.${pkgs.system}.default
  ];

  programs = {
    alacritty = {
      enable = true;
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
  };

  # Home Manager Persistence
  home.persistence."/persist/home/maroka" = {
    allowOther = true;
    files = [
      ".p10k.zsh"
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/Mullvad VPN/gui_settings.json"
      ".config/WebCord/config.json"
      ".config/btop/btop.conf"
      ".config/cat_installer/ca.pem" # eduroam wifi certificate
      ".local/share/nvim/telescope_history"
      ".gnupg"
      ".config/JetBrains"
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
      ".config/WebCord/Local Storage/leveldb"
      ".local/share/direnv/allow"
      ".config/github-copilot"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
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
}
