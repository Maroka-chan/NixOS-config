{ username, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/development/default.nix
    ./niri.nix
  ];

  filesystem.btrfs.enable = true;

  users.mutableUsers = true;
  users.users.${username}.initialPassword = "test123";

  nix.settings.trusted-users = [ "${username}" ];

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  configured.programs.firefox.enableLocalExtensions = false;
  configured.programs.firefox.maxSearchResults = 10;

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    ollama = {
      enable = true;
      acceleration = "rocm";
    };
    mediamtx = {
      enable = true;
      settings = {
        hlsSegmentDuration = "0.01s";
        hlsPartDuration = "1ms";
        hlsSegmentMaxSize = "10M";
        paths = {
          stream = {};
        };
      };
    };
  };

  systemd.services.sshd.wantedBy = lib.mkForce [];
  systemd.services.tailscaled.wantedBy = lib.mkForce [];
  systemd.services.mediamtx.wantedBy = lib.mkForce [];

  networking.firewall = {
    allowedTCPPorts = [ 21412 8888 8890 8554 25565 ];
    allowedUDPPorts = [ 21412 8888 8890 8554 25565 ];
  };

  # Git
  #programs.git.config.user.signingkey = "6CF9E05D378A01C5";

  ### Programs ###
  # VPN
  configured.programs.mullvad.enable = true;
  # Games
  programs.steam.enable = true;

  # Editors
  configured.programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  configured.programs.vscodium = {
    enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
