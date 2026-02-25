inputs: let
  baseModules = with inputs; [
    ../modules
    impermanence.nixosModules.impermanence
    agenix.nixosModules.default
    disko.nixosModules.disko
    home-manager.nixosModules.default
    neovim.nixosModules.default
    nur.modules.nixos.default
    mikuboot.nixosModules.default
    nix-index-database.nixosModules.nix-index
  ];

  desktopModules = [
    ../modules/unstable.nix
    ../modules/development
    ../modules/edot.nix
    (
      {
        config,
        lib,
        username,
        ...
      }: {
        home-manager.enable = true;
        users.users.${username} = {
          isNormalUser = true;
          group = username;
          extraGroups = ["wheel"];
        };
        users.groups.${username} = {};

        # Git
        programs.git = {
          enable = true;
          config = {
            commit.gpgsign =
              builtins.any (
                conf: lib.hasAttrByPath ["user" "signingkey"] conf
              )
              config.programs.git.config;
            core.autocrlf = "input";
          };
        };
      }
    )
  ];

  serverModules = [
  ];

  mkSystem = name: {
    system ? "x86_64-linux",
    channel ? inputs.nixpkgs-unstable,
    useImpermanence ? true,
    isServer ? false,
    username ? "maroka",
  }:
    channel.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs username isServer;};
      modules =
        baseModules
        ++ (
          if isServer
          then serverModules
          else desktopModules
        )
        ++ [
          (
            {lib, ...}: {
              imports = [./${name}/configuration.nix];
              nixpkgs.overlays = [
                (final: prev: {
                  lib =
                    prev.lib
                    // {
                      fetchGHUrl = import ../lib/fetchGHUrl.nix {
                        inherit
                          (final)
                          lib
                          runCommand
                          jq
                          curl
                          cacert
                          ;
                      };
                    };
                })
              ];
              networking.hostName = name;
              impermanence.enable = lib.mkIf useImpermanence true;
              users.mutableUsers = lib.mkDefault false;
              age.identityPaths = [
                (
                  lib.optionalString useImpermanence "/persist"
                  + (
                    if isServer
                    then "/etc/ssh/ssh_host_ed25519_key"
                    else "/home/${username}/.ssh/id_ed25519"
                  )
                )
              ];
            }
          )
        ];
    };
in
  inputs.nixpkgs.lib.mapAttrs mkSystem {
    aisaka = {}; # Laptop
    kanan = {}; # Desktop
    v00334 = {}; # Work Laptop
    akebi = {
      # Home Server
      username = "deploy";
      channel = inputs.nixpkgs-small;
      isServer = true;
    };
    BMJ-Desktop = {
      username = "albmj";
      useImpermanence = false;
    };
    BMJ-Duo = {
      username = "albmj";
      useImpermanence = true;
    };
    V00165 = {
      username = "albmj";
      useImpermanence = false;
    };
    V00652 = {
      username = "albmj";
      useImpermanence = false;
    };
  }
