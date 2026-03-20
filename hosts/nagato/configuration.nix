{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs.nix
    ./deployment-user.nix
    ./networkshare-user.nix
    ../../modules/hardware/gpu/nvidia.nix
    ./reverse-proxy.nix
    ./services
  ];

  nix.settings.trusted-users = ["deploy"];
  filesystem.btrfs.enable = true;

  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  system.stateVersion = "25.11";
}
