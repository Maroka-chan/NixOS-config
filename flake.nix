{
  description = "A Personal NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

  outputs = inputs @ { self, nixpkgs, home-manager, nixos-generators, impermanence, sops-nix, hyprland, anyrun, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations."aisaka" = nixpkgs.lib.nixosSystem {
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
    
    packages."${system}"."aisaka-iso" = nixos-generators.nixosGenerate {
      inherit system;
      format = "install-iso";
      modules = [ ./hosts/aisaka/iso ];
    };
  };
}
