{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/input/japanese.nix
  ];

  nix.settings.trusted-users = ["maroka"];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  xdg.portal.config.common."org.freedesktop.impl.portal.AppChooser" = "gtk";

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  boot.plymouth = {
    enable = true;
    themePackages = [pkgs.mikuboot];
    theme = "mikuboot";
  };

  fonts.packages = with pkgs; [
    material-symbols
    nerd-fonts.jetbrains-mono
    ibm-plex
  ];

  # Users
  age.secrets."${username}-password".file = ../../secrets/${username}-password.age;
  users.users.${username} = {
    hashedPasswordFile = config.age.secrets."${username}-password".path;
    extraGroups = [
      "podman"
    ];
  };

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  #desktops.hyprland.enable = true;
  #desktops.hyprland.extraConfig = ''
  #  monitor=DP-3,2560x1440@240,0x0,1

  #  exec-once = swaybg -i ${../../dotfiles/wallpapers/makima.png} -m fill
  #  exec-once = ags run --gtk 3
  #'';
  desktops.niri.enable = true;
  desktops.niri.avatarHash = "sha256-gr/MY41IW26UD48sAjR778ST6LvhnZhgwKRUV8csCCY=";
  desktops.niri.extraConfig = ''
    output "DP-3" {
        mode "2560x1440@239.970"
        scale 1
        transform "normal"
    }
  '';

  # Git
  programs.git.config.user.signingkey = "6CF9E05D378A01C5";

  ### Programs ###
  # VPN
  configured.programs.mullvad.enable = true;
  # Stremio
  configured.programs.stremio.enable = true;
  # Games
  programs.steam.enable = true;

  # Editor
  programs.neovim-monica = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
