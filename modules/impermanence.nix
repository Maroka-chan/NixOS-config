{ inputs, lib, config, username, isServer, ... }:
let
  module_name = "impermanence";
  cfg = config."${module_name}";
  inherit (lib) mkEnableOption mkMerge mkIf;
in {
  options."${module_name}" = {
    enable = mkEnableOption "Wipe root and restore root to a blank snapshot on boot";
  };

  config = mkMerge [
  (mkIf cfg.enable {
    # Files to persist
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/fwupd"
      ];
      files = [
        "/etc/machine-id"
        "/var/lib/systemd/random-seed"
      ];
    };

    # Workaround for the following service failing with a bind mount for /etc/machine-id
    # see: https://github.com/nix-community/impermanence/issues/229
    boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

    # Configure Disko VM
    virtualisation.vmVariantWithDisko.virtualisation.fileSystems."/persist".neededForBoot = true;
  })
  (mkIf (!isServer) {
    home-manager.users.${username}.imports = [
      inputs.impermanence.nixosModules.home-manager.impermanence
    ];
  })];
}
