{
  outputs = inputs @ { self, nixpkgs, deploy-rs, ... }:
  {
    nixosConfigurations = import ./hosts inputs;

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

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-24.11-small";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    nixpkgs-stremio-server.url = "github:NixOS/nixpkgs/aae94e56a7b905281f007a5b70aa7ffff89aee57";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    transmission_4_5.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";

    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs-unstable";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    ags.url = "github:Aylur/ags";
    walker.url = "github:abenz1267/walker";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";

    tlock.url = "git+https://github.com/eklairs/tlock?submodules=1";
    tlock.inputs.nixpkgs.follows = "nixpkgs-unstable";

    neovim.url = "github:Maroka-chan/nvim-config";
    shutoku.url = "git+ssh://git@github.com/Maroka-chan/Shutoku-rs";
    shutoku.inputs.nixpkgs.follows = "nixpkgs-unstable";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    umu = {
      url = "git+https://github.com/Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };

    hoyonix.url = "git+ssh://git@github.com/Maroka-chan/hoyonix";
    hoyonix.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
}
