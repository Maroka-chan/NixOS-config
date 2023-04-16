{
    description = "My NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11-small";
    };

    outputs = { self, nixpkgs, ... }:
    {
        colmena = {
            meta = {
                nixpkgs = import nixpkgs {
                    system = "x86_64-linux";
                    overlays = [];
                };
            };

            akebi = { name, nodes, pkgs, ... }: {
                imports = [
                    ./system/akebi/hardware-configuration.nix
                    ./system/akebi/configuration.nix
                ];

                deployment.targetHost = "akebi";
                deployment.targetUser = "deploy";
                deployment.buildOnTarget = true;
            };
        };
    };
}