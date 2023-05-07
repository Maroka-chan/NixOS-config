{
    description = "My NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11-small";
        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        impermanence.url = "github:nix-community/impermanence";
    };

    outputs = { self, nixpkgs, nixos-generators, impermanence, ... }:
    let
        akebi-path = "./system/akebi";
        akebi-modules = [
            "${akebi-path}"/hardware-configuration.nix
            "${akebi-path}"/configuration.nix
            impermanence.nixosModules.impermanence
            "${akebi-path}"/impermanence.nix
        ];
    in
    {
        nixosConfigurations = {
            akebi = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = akebi-modules;
            };
            akebi-vm = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./system/akebi/configuration.nix
                    ./system/akebi/vm.nix
                ];
            };
        };

        colmena = {
            meta = {
                nixpkgs = import nixpkgs {
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
                    ./system/akebi/iso.nix
                ];

                format = "install-iso";
            };
        };
    };
}