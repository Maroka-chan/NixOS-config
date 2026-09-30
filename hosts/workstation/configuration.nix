{
  username,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/gpu/nvidia.nix
    ../../modules/development/default.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ./niri.nix
  ];

  # Full disk encryption: LUKS2 (FIDO2 unlock) -> btrfs, see btrfs_luks_impermanence.nix
  # The disko module takes the target disk as a module argument.
  _module.args.OSDisk = "/dev/disk/by-id/nvme-Corsair_MP600_CORE_XT_23208047000132640514";

  filesystem.btrfs.enable = true;

  # RTX 4090 (Ada Lovelace) -> use the open kernel modules
  hardware.nvidia = {
    open = true;
    # Save/restore VRAM on suspend, avoids a corrupted session on resume under Wayland
    powerManagement.enable = true;
  };

  users.mutableUsers = true;
  users.users.${username} = {
    initialPassword = "password";
    extraGroups = [
      "networkmanager"
      "dialout"
      "podman"
      "wireshark"
    ];
  };

  nix.settings.trusted-users = ["${username}"];

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

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
    printing.enable = false;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  systemd.services.cups.wantedBy = lib.mkForce [];
  systemd.services.sshd.wantedBy = lib.mkForce [];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Git
  #programs.git.config.user.signingkey = "6CF9E05D378A01C5";

  ### Programs ###

  configured.programs.firefox.enableLocalExtensions = false;
  configured.programs.firefox.maxSearchResults = 10;

  # Editors
  programs.neovim-monica = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    usbmon.enable = true;
    dumpcap.enable = true;
  };

  # cnping
  programs.cnping.enable = true;

  configured.programs.vscode.enable = true;

  networking.firewall.allowedUDPPorts = [
    53
    67
    68
  ];

  services.udev.extraRules = ''
    # FTDI
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6011", MODE="0666"

    # Jetson
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}=="7c18", MODE="0666"

    # ADVANTECH QCOM
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="05c6", ATTRS{idProduct}=="9008", MODE="0666"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
