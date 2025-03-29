{ pkgs, lib, inputs, username, ... }:
let
  homeDirectory = "/home/${username}";
  custom-extensions = import ./vscode.nix { inherit pkgs lib; };
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    # Media players
    jellyfin-media-player

    swaybg    # Wallpaper Tool

    sshfs     # Remote filesystems over SSH
    vesktop   # Third-party Discord

    inkscape
    prismlauncher # Minecraft Launcher

    inputs.neovim.packages.${pkgs.system}.default
    wl-clipboard
  ];

  programs = {
    git = {
      enable = true;
      userName = "AlexBMJ";
      userEmail = "33891167+AlexBMJ@users.noreply.github.com";
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    obs-studio.enable = true;
    vscode = {
      enable = true;
      profiles.default = {
        enableUpdateCheck = false;
        extensions = with pkgs.vscode-extensions; with custom-extensions; [
          rust-lang.rust-analyzer
          ms-python.python
          mads-hartmann.bash-ide-vscode
          github.copilot
          lakshits11.monokai-pirokai
        ];
        userSettings = {
          "editor.fontFamily" = "'CaskaydiaCove Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
        };
      };
    };
  };
}
