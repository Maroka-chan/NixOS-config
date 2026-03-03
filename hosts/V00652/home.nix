{
  pkgs,
  username,
  ...
}: let
  homeDirectory = "/home/${username}";
in {
  home = {inherit username homeDirectory;};

  home.packages = with pkgs; [
    # Tools
    swaybg # Wallpaper Tool
    sshfs # Remote filesystems over SSH
    wl-clipboard # Clipboard Manager
    opencode # LLM Agent

    zoom-us
    slack

    granted # AWS assume role
  ];

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Alexander Jacobsen";
          email = "dev@alexbmj.com";
        };
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    awscli = {
      enable = true;
    };
    zsh.shellAliases = {
      assume = "source assume";
    };
  };
}
