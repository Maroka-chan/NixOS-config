{ inputs, ... }:
let
  baseModules = [
    ../modules
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    ../modules/btrfs-impermanence
  ];

  mkSystem = name: system:
    let lib = system.channel.lib;
    in lib.nixosSystem {
      system = system.arch;
      modules =
        baseModules
        ++ [
          {networking.hostName = name;}
          (import (./. + "/${name}/configuration.nix"))
        ];
      specialArgs = {inherit inputs lib;};
    };

  systems = {
    aisaka = { arch = "x86_64-linux"; channel = inputs.nixpkgs; };
    akebi = { arch = "x86_64-linux"; channel = inputs.nixpkgs-small; };
    v00334 = { arch = "x86_64-linux"; channel = inputs.nixpkgs; };
  };

in inputs.nixpkgs.lib.mapAttrs mkSystem systems
