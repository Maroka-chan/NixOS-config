{ inputs, ... }:
let
  baseModules = with inputs; [
    ../modules
    impermanence.nixosModules.impermanence
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
    ../modules/btrfs-impermanence
  ];

  mkSystem = name: {
    system,
    channel
  }:
    let lib = channel.lib;
    in lib.nixosSystem {
      inherit system;
      modules =
        baseModules
        ++ [
          {networking.hostName = name;}
          (import (./. + "/${name}/configuration.nix"))
        ];
      specialArgs = {inherit inputs lib;};
    };

  systems = {
    aisaka    = { system = "x86_64-linux"; channel = inputs.nixpkgs; };
    kanan     = { system = "x86_64-linux"; channel = inputs.nixpkgs; };
    akebi     = { system = "x86_64-linux"; channel = inputs.nixpkgs-small; };
    v00334    = { system = "x86_64-linux"; channel = inputs.nixpkgs; };
  };

in inputs.nixpkgs.lib.mapAttrs mkSystem systems
