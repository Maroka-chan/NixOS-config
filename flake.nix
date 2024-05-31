{
  description = "A Personal NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-23.11-small";
    nixpkgs-release.url = "github:NixOS/nixpkgs/release-23.11";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    hyprlock.url = "github:hyprwm/hyprlock";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    shutoku.url = "git+ssh://git@github.com/Maroka-chan/Shutoku-rs";
    shutoku.inputs.nixpkgs.follows = "nixpkgs-unstable";
    vpnconfinement.url = "github:Maroka-chan/VPN-Confinement";
    neovim.url = "github:Maroka-chan/nvim-config";
    tlock.url = "git+https://github.com/eklairs/tlock?submodules=1";
    tlock.inputs.nixpkgs.follows = "nixpkgs-unstable";
    ags.url = "github:Aylur/ags";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixos-generators, deploy-rs, ... }:
  {
    nixosConfigurations = import ./hosts { inherit inputs; };

    deploy.nodes.akebi = {
      hostname = "akebi";
      profiles = {
        system = {
          sshUser = "deploy";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.akebi;
          user = "root";
        };
      };
      remoteBuild = true;
    };

    # This is highly advised, and will prevent many possible mistakes
    checks =
      builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;


    ### ISO's ###
   # packages."${system}" = {
   #   aisaka-iso = nixos-generators.nixosGenerate {
   #     inherit system;
   #     format = "install-iso";
   #     modules = [ ./hosts/aisaka/iso ];
   #   };
   #   akebi-iso = nixos-generators.nixosGenerate {
   #     inherit system;
   #     format = "install-iso";
   #     modules = [ ./hosts/akebi/iso.nix ];
   #   };
   # };
  };
}
