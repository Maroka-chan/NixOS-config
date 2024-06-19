{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    nil # Nix LSP
    nixpkgs-fmt # Nix Formatter
    #nodePackages.bash-language-server
  ];
}

