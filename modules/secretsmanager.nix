{ config, pkgs, lib, ... }: let
  inherit (lib) mkOption concatMapAttrsStringSep;
  inherit (lib.types) attrsOf submodule path str;

  secretOptions = { name, config, ... }:
    {
      options = {
        uuid = mkOption {
          type = str;
        };

        path = mkOption {
          type = path;
          readOnly = true;
          default = "/run/secrets/${name}";
        };
      };
    };
in {
  options.secrets = mkOption {
    type = attrsOf (submodule secretOptions);
    default = {};
  };

  config = {
    system.activationScripts.secret-installer = let
      secretsMountPoint = "/run/secrets";
    in {
      text = "${pkgs.writeShellApplication {
        name = "install-secrets";
        runtimeInputs = with pkgs; [
          bws
          jq
        ];
        text = ''
          mkdir -p "${secretsMountPoint}"
          chmod 0751 "${secretsMountPoint}"

          grep -q "${secretsMountPoint} ramfs" /proc/mounts &&
            (echo "[secrets] removing existing secrets"; umount "${secretsMountPoint}")
          mount -t ramfs none "${secretsMountPoint}" -o nodev,nosuid,mode=0751

          umask u=r,g=,o=
          ${concatMapAttrsStringSep "\n" (name: value: ''
            echo "[secrets] installing '${name}'"
            bws secret get ${value.uuid} --access-token "$(</persist/home/maroka/Downloads/access_token)" |
	    	jq --raw-output '.value' > "${secretsMountPoint}/${name}"
          '') config.secrets}
        '';
      }}/bin/install-secrets";
      deps = [
        "specialfs"
      ];
    };
  };
}
