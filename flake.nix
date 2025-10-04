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

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs-stremio-server.url = "github:NixOS/nixpkgs/aae94e56a7b905281f007a5b70aa7ffff89aee57";
    transmission_4_5.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixos-hardware-gpdduo.url = "github:AlexBMJ/nixos-hardware/gpd-duo";

    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # We break binary cache if hyprland follows our nixpkgs
    hyprland.url = "github:hyprwm/Hyprland";

    split-monitor-workspaces.url = "github:Duckonaut/split-monitor-workspaces";
    split-monitor-workspaces.inputs.hyprland.follows = "hyprland";

    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs-unstable";

    walker.url = "github:abenz1267/walker/0.13.26";
    walker.inputs.nixpkgs.follows = "nixpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    neovim.url = "github:Maroka-chan/nvim-config";
    neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    mikuboot.url = "gitlab:evysgarden/mikuboot";
    mikuboot.inputs.nixpkgs.follows = "nixpkgs-unstable";

    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging\/nix&submodules=1";
    umu.inputs.nixpkgs.follows = "nixpkgs-unstable";

    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    yuttari.url = "git+ssh://git@github.com/Maroka-chan/yuttari-rs";
    yuttari.inputs.nixpkgs.follows = "nixpkgs-unstable";

    hoyonix.url = "git+ssh://git@github.com/Maroka-chan/hoyonix";
    hoyonix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    hoyonix.inputs.umu.follows = "umu";

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.quickshell.follows = "quickshell";
    };
  };
}
