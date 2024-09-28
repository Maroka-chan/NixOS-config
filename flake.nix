{
  description = "A Personal NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-24.05-small";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    nixpkgs-stremio-server.url = "github:NixOS/nixpkgs/aae94e56a7b905281f007a5b70aa7ffff89aee57";
    nixpkgs-fork.url = "path:///home/maroka/Documents/nixpkgs";

    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland.inputs.nixpkgs.follows = "nixpkgs-unstable";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    ags.url = "github:Aylur/ags";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";

    tlock.url = "git+https://github.com/eklairs/tlock?submodules=1";
    tlock.inputs.nixpkgs.follows = "nixpkgs-unstable";

    neovim.url = "github:Maroka-chan/nvim-config";
    neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    shutoku.url = "git+ssh://git@github.com/Maroka-chan/Shutoku-rs";
    shutoku.inputs.nixpkgs.follows = "nixpkgs-unstable";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    vpn-confinement.inputs.nixpkgs.follows = "nixpkgs-unstable";

    umu = {
      url = "git+https://github.com/Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };

    hoyonix.url = "path:///home/maroka/Documents/hoyonix";
    hoyonix.inputs.nixpkgs.follows = "nixpkgs-unstable";

  };

  outputs = inputs @ { self, nixpkgs, deploy-rs, ... }:
  {
    nixosConfigurations = import ./hosts { inherit inputs; };

    deploy.nodes.akebi = {
      hostname = "akebi";
      remoteBuild = false;
      profiles.system = {
        user = "root";
        sshUser = "deploy";
        path =
          deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.akebi;
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks =
      builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.mkShell {
      packages = [ pkgs.deploy-rs ];
    };
  };
}
