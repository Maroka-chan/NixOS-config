{ inputs, ... }:
let
  baseModules = with inputs; [
    ../modules
    impermanence.nixosModules.impermanence
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
  ];

  mkSystem = name: {
    system,
    channel
  }:
    let
      lib = channel.lib;
      overlay = final: prev: {
      };
    in lib.nixosSystem {
      inherit system;
      modules =
        baseModules
        ++ [
          { networking.hostName = name; }
          { nixpkgs.overlays = [ overlay ]; }
          (import (./. + "/${name}/configuration.nix"))
        ];
      specialArgs = { inherit inputs; };
    };

  systems = {
    aisaka    = { system = "x86_64-linux"; channel = inputs.nixpkgs-unstable; };
    kanan     = { system = "x86_64-linux"; channel = inputs.nixpkgs-unstable; };
    akebi     = { system = "x86_64-linux"; channel = inputs.nixpkgs-small; };
    v00334    = { system = "x86_64-linux"; channel = inputs.nixpkgs-unstable; };
  };

in inputs.nixpkgs.lib.mapAttrs mkSystem systems
