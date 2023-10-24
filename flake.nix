{
  description = "A Personal NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-23.05-small";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-small, home-manager, nixos-generators, impermanence, sops-nix, hyprland, anyrun, ... }:
  let
    system = "x86_64-linux";
  in
  {
    ### Aisaka ###

    nixosConfigurations.aisaka = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./hosts/aisaka/configuration.nix
        ./hosts/aisaka/hardware-configuration.nix
        ./modules/btrfs-impermanence
        impermanence.nixosModules.impermanence
        sops-nix.nixosModules.sops
        hyprland.nixosModules.default {
          programs.hyprland.enable = true;
        }
        home-manager.nixosModules.home-manager {
          programs.fuse.userAllowOther = true;
          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            useGlobalPkgs = true;
            useUserPackages = true;
            users.maroka = {
              home = {
                username = "maroka";
                homeDirectory = "/home/maroka";
                packages = [ anyrun.packages.${system}.anyrun ];
              };
              imports = [
                impermanence.nixosModules.home-manager.impermanence
                hyprland.homeManagerModules.default
                anyrun.homeManagerModules.default
                ./hosts/aisaka/home.nix
                ./modules/nvim
              ];
            };
          };
        }
      ];
    };


    ### Akebi ###

    nixosConfigurations = {
      akebi = nixpkgs-small.lib.nixosSystem {
        inherit system;
        modules = [
          impermanence.nixosModules.impermanence
          ./hosts/akebi/impermanence.nix
          ./hosts/akebi/hardware-configuration.nix
          ./hosts/akebi/configuration.nix
        ];
      };
      akebi-vm = nixpkgs-small.lib.nixosSystem {
        inherit system;
        modules = [
            ./hosts/akebi/configuration.nix
            ./hosts/akebi/vm.nix
        ];
      };
    };

    colmena = {
      meta = {
        nixpkgs = import nixpkgs-small {
          inherit system;
          overlays = [];
        };
      };

      akebi = { name, nodes, pkgs, ... }: 
      {
        import = self.nixosConfigurations.akebi.modules;

        deployment.targetHost = "akebi";
        deployment.targetUser = "deploy";
        deployment.buildOnTarget = true;
      };
    };


    ### ISO's ###
    packages."${system}" = {
      aisaka-iso = nixos-generators.nixosGenerate {
        inherit system;
        format = "install-iso";
        modules = [ ./hosts/aisaka/iso ];
      };
      akebi-iso = nixos-generators.nixosGenerate {
        inherit system;
        format = "install-iso";
        modules = [ ./hosts/akebi/iso.nix ];
      };
    };
  };
}
