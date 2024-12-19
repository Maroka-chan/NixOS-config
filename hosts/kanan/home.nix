{ config, pkgs, inputs, username, ... }:
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
    inkscape

    inputs.neovim.packages.${pkgs.system}.default
    inputs.tlock.packages.${pkgs.system}.default
  ];

  programs = {
    walker.enable = true;
    walker.theme = {
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
    alacritty.enable = true;
    password-store.enable = true;
    gpg.enable = true;
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
    firefox.enable = true;
    obs-studio.enable = true;
  };

  # Home Manager Persistence
  home.persistence."/persist${homeDirectory}" = {
    allowOther = true;
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
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
      ".config/protonmail/bridge-v3"
      ".local/share/protonmail/bridge-v3"
      ".local/share/DaVinciResolve"
      ".local/share/bottles"
      ".local/share/tlock"
      ".local/state/wireplumber"
      ".local/share/Steam"
    ];
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

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/config/eww";
  
  # Alacritty
  xdg.configFile."alacritty".source = "${dotfiles}/config/alacritty";
}
