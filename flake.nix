{
  outputs = inputs @ {
    self,
    nixpkgs,
    deploy-rs,
    ...
  }: {
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

    deploy.nodes.nagato = {
      hostname = "nagato.management.bmj";
      remoteBuild = false;
      profiles.system = {
        user = "root";
        sshUser = "deploy";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nagato;
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        packages = [pkgs.deploy-rs];
      };
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-25.11-small";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-stremio-server.url = "github:NixOS/nixpkgs/aae94e56a7b905281f007a5b70aa7ffff89aee57";
    transmission_4_5.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware-gpdduo.url = "github:AlexBMJ/nixos-hardware/gpd-duo";

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "";
    impermanence.inputs.home-manager.follows = "";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    neovim.url = "github:Maroka-chan/nvim-config";
    neovim.inputs.nixpkgs.follows = "nixpkgs";

    nix4vscode.url = "github:nix-community/nix4vscode";
    nix4vscode.inputs.nixpkgs.follows = "nixpkgs";

    mikuboot.url = "gitlab:evysgarden/mikuboot";
    mikuboot.inputs.nixpkgs.follows = "nixpkgs";

    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging\/nix&submodules=1";
    umu.inputs.nixpkgs.follows = "nixpkgs";

    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    yuttari.url = "git+ssh://git@github.com/Maroka-chan/yuttari-rs";
    yuttari.inputs.nixpkgs.follows = "nixpkgs";

    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
  };
}
