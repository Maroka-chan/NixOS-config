inputs:
let
  baseModules = with inputs; [
    ../modules
    impermanence.nixosModules.impermanence
    agenix.nixosModules.default
    disko.nixosModules.disko
    home-manager.nixosModules.default
    hyprland.nixosModules.default
    nur.modules.nixos.default
    {
      users.mutableUsers = false;
    }
  ];

  desktopModules = with inputs; [
    ../modules/unstable.nix
    ../modules/development
    ({ username, ... }: {
      home-manager.enable = true;
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    })
  ];

  serverModules = with inputs; [
  ];

  mkSystem = name: {
    system ? "x86_64-linux",
    channel ? inputs.nixpkgs-unstable,
    useImpermanence ? true,
    isServer ? false,
    username ? "maroka"
  }: channel.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username isServer; };
      modules =
        baseModules
        ++
        (if isServer then serverModules else desktopModules)
        ++
        [({ lib, ... }: {
          imports = [ ./${name}/configuration.nix ];
          networking.hostName = name;
          impermanence.enable = lib.mkIf useImpermanence true;
          age.identityPaths = [(
            lib.optionalString useImpermanence "/persist"
            +
            (if isServer
              then "/etc/ssh/ssh_host_ed25519_key"
              else "/home/${username}/.ssh/id_ed25519"
            )
          )];
        })];
    };

in inputs.nixpkgs.lib.mapAttrs mkSystem {
  aisaka = {};  # Laptop
  kanan  = {};  # Desktop
  v00334 = {};  # Work Laptop
  akebi  = {    # Home Server
    channel = inputs.nixpkgs-small;
    isServer = true;
  };
}
