{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    nil # Nix LSP
    nixpkgs-fmt # Nix Formatter
    nodePackages.bash-language-server

    # Should be defined in nvim-config and eww/ags bar module
    inotify-tools
    ripgrep
    jq
    socat
  ];
}

