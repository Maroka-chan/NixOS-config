{
    description = "My NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11-small";
        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        impermanence = {
            url = "github:nix-community/impermanence";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, nixos-generators, impermanence, ... }:
    {
        nixosConfigurations = {
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
                imports = [
                    ./system/akebi/hardware-configuration.nix
                    ./system/akebi/configuration.nix
                    impermanence.nixosModules.impermanence
                    ./system/akebi/impermanence.nix
                ];

                deployment.targetHost = "akebi";
                deployment.targetUser = "deploy";
                deployment.buildOnTarget = true;
            };
        };

        packages.x86_64-linux = {
            akebi_iso = nixos-generators.nixosGenerate {
                system = "x86_64-linux";
                modules = [
                    ./system/akebi/iso.nix
                ];

                format = "install-iso";
            };
        };
    };
}