{ config, pkgs, ...}:
let
  dotfiles = config.lib.file.mkOutOfStoreSymlink "/home/maroka/.dotfiles";
in
{

  home.packages = with pkgs; [
    git
    alacritty
    pavucontrol

    # Browsers
    firefox
    brave
    librewolf

    swaybg # Wallpaper Tool
    swayidle
  ];

  programs = {
    alacritty = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;

      history = {
        size = 10000;
        path = "/persist/${config.xdg.dataHome}/zsh/history";
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
        # Needed for marlonrichert/zsh-autocomplete to work correctly
        # https://nixos.wiki/wiki/Zsh#Troubleshooting
        bindkey "''${key[Up]}" up-line-or-search

        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';

      zplug = {
        enable = true;
	plugins = [
          { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
	];
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
      };
    };
    git = {
      enable = true;
      userName = "Maroka-chan";
      userEmail = "64618598+Maroka-chan@users.noreply.github.com";
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
    librewolf = {
      enable = true;
    };
    firefox = {
      enable = true;
    };
  };

  # Home Manager Persistence
  home.persistence."/persist/home/maroka" = {
    allowOther = true;
    files = [
      "${config.programs.zsh.history.path}"
      ".p10k.zsh"
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
    ];
  };

  gtk.enable = true; # Needs to be enabled for home.pointerCursor to actually write gtk XDG settings files
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
    timeouts = [
      { timeout = 120; command = "${pkgs.systemd}/bin/systemctl suspend"; }
    ];
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      monitor=,preferred,auto,1

      exec-once = swaybg -i ${dotfiles}/wallpapers/yume_no_kissaten_yumegatari.png -m fill
      exec-once = eww daemon & eww open bar

      input {
        kb_layout = us
	repeat_rate = 25
	repeat_delay = 200

        touchpad {
          natural_scroll = true
	  scroll_factor = 0.2
	}

      }

      gestures {
        workspace_swipe = true
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
	blur = false
      }

      $mainMod = SUPER

      bind = $mainMod SHIFT, Q, killactive
      bind = $mainMod, F, fullscreen
      bind = $mainMod, D, exec, anyrun
      bind = $mainMod, Return, exec, alacritty
      bind = $mainMod, V, togglefloating
      bind = $mainMod, B, exec, librewolf

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

      # Volume button that allows press and hold, volume limited to 150%
      binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      
      # Volume button that will activate even while an input inhibitor is active
      bindl = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

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
    '';
  };

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/config/eww";

  # Alacritty
  xdg.configFile."alacritty".source = "${dotfiles}/config/alacritty";

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
  home.stateVersion = "23.05";
}
