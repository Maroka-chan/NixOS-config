{ inputs, ... }:
let
  baseModules = with inputs; [
    ../modules
    ../modules/development
    impermanence.nixosModules.impermanence
    agenix.nixosModules.default
    disko.nixosModules.disko
  ];

  mkSystem = name: {
    system,
    channel
  }:
    let
      lib = channel.lib;
      overlay = final: prev: {
        mpv = prev.mpv.override {
          scripts = [ final.mpvScripts.mpris ];
        };
      };
      username = "maroka";
    in lib.nixosSystem {
      inherit system;
      modules =
        baseModules
        ++ [
          { networking.hostName = name; }
          { nixpkgs.overlays = [ overlay ]; }
          { age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; }
          (import (./. + "/${name}/configuration.nix"))
        ];
      specialArgs = { inherit inputs username; };
    };

  systems = {
    aisaka    = { system = "x86_64-linux"; channel = inputs.nixpkgs-unstable; };
    kanan     = { system = "x86_64-linux"; channel = inputs.nixpkgs-unstable; };
    akebi     = { system = "x86_64-linux"; channel = inputs.nixpkgs-small; };
    v00334    = { system = "x86_64-linux"; channel = inputs.nixpkgs-unstable; };
  };

in inputs.nixpkgs.lib.mapAttrs mkSystem systems
