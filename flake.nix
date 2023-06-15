{
    description = "My NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11-small";
        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        impermanence.url = "github:nix-community/impermanence";
        sops-nix.url = "github:Mic92/sops-nix";
    };

    outputs = { self, nixpkgs, nixos-generators, impermanence, sops-nix, ... }:
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
            akebi = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = akebi-modules;
            };
            akebi-vm = nixpkgs.lib.nixosSystem {
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
                    "${akebi-path}/iso.nix"
                ];

                format = "install-iso";
            };
            aisaka-iso = nixos-generators.nixosGenerate {
                system = "x86_64-linux";
                modules = [
                    "${aisaka-path}/iso.nix"
                ];

                format = "install-iso";
            };
        };
    };
}