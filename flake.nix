{
  description = "My NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11-small";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, sops-nix, arion }:
    {
        nixosConfigurations = {
            akebi = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./system/akebi/configuration.nix
                    sops-nix.nixosModules.sops
                ];
            };
        };
    };
}
