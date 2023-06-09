{
    description = "My NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-23.05-small";
        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        impermanence.url = "github:nix-community/impermanence";
        sops-nix.url = "github:Mic92/sops-nix";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        hyprland.url = "github:hyprwm/Hyprland";
    };

    outputs = { self, nixpkgs, nixpkgs-small, nixos-generators, impermanence, sops-nix, home-manager, hyprland, ... }:
    let
        akebi-path = ./. + "/hosts/akebi";
        aisaka-path = ./. + "/hosts/aisaka";
        akebi-modules = [
            "${akebi-path}/hardware-configuration.nix"
            "${akebi-path}/configuration.nix"
            impermanence.nixosModules.impermanence
            "${akebi-path}/impermanence.nix"
            "${akebi-path}/podman.nix"
            "${akebi-path}/services/jellyfin"
            "${akebi-path}/services/transmission"
        ];
    in
    {
        nixosConfigurations = {
            akebi = nixpkgs-small.lib.nixosSystem {
                system = "x86_64-linux";
                modules = akebi-modules;
            };
            akebi-vm = nixpkgs-small.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    "${akebi-path}/configuration.nix"
                    "${akebi-path}/vm.nix"
                ];
            };
            aisaka = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    "${aisaka-path}/configuration.nix"
                    "${aisaka-path}/hardware-configuration.nix"
                    impermanence.nixosModules.impermanence
                    sops-nix.nixosModules.sops
                    ./modules/btrfs-impermanence
                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.maroka = {
                            home.username = "maroka";
                            home.homeDirectory = "/home/maroka";
                            imports = [
                                impermanence.nixosModules.home-manager.impermanence
                                hyprland.homeManagerModules.default
                                "${aisaka-path}/home.nix"
                            ];
                        };
                    }
                    hyprland.nixosModules.default {
                        programs.hyprland.enable = true;
                    }
                ];
            };
        };

        colmena = {
            meta = {
                nixpkgs = import nixpkgs-small {
                    system = "x86_64-linux";
                    overlays = [];
                };
            };

            akebi = { name, nodes, pkgs, ... }: 
            {
                imports = akebi-modules;

                deployment.targetHost = "akebi";
                deployment.targetUser = "deploy";
                deployment.buildOnTarget = true;
            };
        };

        packages.x86_64-linux = {
            akebi-iso = nixos-generators.nixosGenerate {
                system = "x86_64-linux";
                modules = [
                    "${akebi-path}/iso.nix"
                ];

                format = "install-iso";
            };
            aisaka-iso = nixos-generators.nixosGenerate {
                system = "x86_64-linux";
                modules = [
                    "${aisaka-path}/iso"
                ];

                format = "install-iso";
            };
        };
    };
}