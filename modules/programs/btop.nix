{
  pkgs,
  lib,
  config,
  username,
  ...
}:
with lib; let
  module_name = "btop";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable =
      mkEnableOption "Enable btop with access to privileged stats without sudo"
      // {default = true;};
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.btop];

    security.wrappers.btop = {
      owner = "root";
      group = "root";
      setuid = false;
      capabilities = "cap_perfmon+ep";
      source = "${pkgs.btop}/bin/btop";
    };

    # CPU package power (RAPL energy_uj) is root-only since the
    # PLATYPUS mitigation. Make it group-readable for a dedicated group
    # instead of granting btop cap_dac_read_search (read any file).
    users.groups.powermon = {};
    users.users.${username}.extraGroups = ["powermon"];
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="powercap", TEST=="energy_uj", RUN+="${pkgs.coreutils}/bin/chgrp powermon /sys%p/energy_uj", RUN+="${pkgs.coreutils}/bin/chmod 0440 /sys%p/energy_uj"
    '';
  };
}
