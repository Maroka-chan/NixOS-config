{
  outputs =
    inputs@{
      self,
      nixpkgs,
      deploy-rs,
      ...
    }:
    {
      nixosConfigurations = import ./hosts inputs;
      #homeConfigurations = {
      #  "maroka@kanan" = inputs.home-manager.lib.homeManagerConfiguration {
      #    pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #    extraSpecialArgs = { inherit inputs; username = "maroka"; };
      #    modules = [
      #      (self.nixosConfigurations.kanan.config.home-manager)
      #    ];
      #  };
      #};

      deploy.nodes.akebi = {
        hostname = "akebi";
        remoteBuild = false;
        profiles.system = {
          user = "root";
          sshUser = "deploy";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.akebi;
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          packages = [ pkgs.deploy-rs ];
        };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-25.05-small";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    nixos-hardware-gpdduo.url = "github:AlexBMJ/nixos-hardware/gpd-duo";
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
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    ags.url = "github:Aylur/ags";
    walker.url = "github:abenz1267/walker/0.13.26";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";

    neovim.url = "github:Maroka-chan/nvim-config";
    neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    yuttari.url = "git+ssh://git@github.com/Maroka-chan/yuttari-rs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    umu = {
      url = "github:Open-Wine-Components/umu-launcher?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };

    hoyonix.url = "git+ssh://git@github.com/Maroka-chan/hoyonix";
    hoyonix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    hoyonix.inputs.umu.follows = "umu";

    mikuboot = {
      url = "gitlab:evysgarden/mikuboot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
