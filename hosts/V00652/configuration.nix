{
  username,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/development/default.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ./niri.nix
  ];

  filesystem.btrfs.enable = true;

  users.mutableUsers = true;
  users.users.${username} = {
    initialPassword = "password";
    extraGroups = [
      "networkmanager"
      "dialout"
      "podman"
    ];
  };

  nix.settings.trusted-users = ["${username}"];

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  services.resolved.enable = true;
  services.upower.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = ["ve-mdm-ubuntu"];

  # Host-side veth for MDM container (DHCP server + NAT)
  systemd.network.enable = true;
  systemd.network.networks."80-ve-mdm-ubuntu" = {
    matchConfig.Name = "ve-mdm-ubuntu";
    address = ["10.0.100.1/24"];
    networkConfig = {
      IPMasquerade = "ipv4";
      IPv4Forwarding = "yes";
      IPv6AcceptRA = "no";
      LinkLocalAddressing = "ipv4";
      DHCPServer = "yes";
    };
    dhcpServerConfig = {
      PoolOffset = 10;
      PoolSize = 20;
      EmitDNS = true;
      DNS = ["1.1.1.1" "8.8.8.8"];
    };
  };

  services = {
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          energy_performance_preference = "performance";
          governor = "performance";
          turbo = "always";
          enable_thresholds = true;
          start_threshold = 60;
          stop_threshold = 80;
        };
        charger = {
          energy_performance_preference = "performance";
          governor = "performance";
          turbo = "always";
        };
      };
    };
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
    printing.enable = true;
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

  # cnping
  programs.cnping.enable = true;

  configured.programs.vscode.enable = true;

  networking.firewall.allowedUDPPorts = [
    53
    67
    68
  ];

  services.udev.extraRules = ''
        # Backlight
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"

        # FTDI
        SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6011", MODE="0666"

        # Jetson
        SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}="7c18", MODE="0666"

        # ADVANTECH QCOM
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="05c6", ATTRS{idProduct}=="9008", MODE="0666",
    GROUP="plugdev"
  '';

  # HEXNODE CONTAINER
  systemd.services.mdm-ubuntu-container = let
    rcLocal = pkgs.writeScript "rc.local" ''
      #!/bin/bash
      if [ ! -f /root/.enrolled ]; then
        /root/config && touch /root/.enrolled
      fi
    '';
    containerNetworkConfig = pkgs.writeText "80-host0.network" ''
      [Match]
      Name=host0

      [Network]
      DHCP=ipv4
    '';
  in {
    description = "Ubuntu 24.04 Container for Hexnode MDM";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    path = with pkgs; [debootstrap systemd bash coreutils];

    preStart = ''
      mkdir -p /var/lib/machines/mdm-ubuntu

      if [ ! -f /var/lib/machines/mdm-ubuntu/.setup-complete ]; then
        rm -rf /var/lib/machines/mdm-ubuntu/
        echo "Bootstrapping Ubuntu 24.04 (Noble)... This may take a few minutes."
        debootstrap noble /var/lib/machines/mdm-ubuntu http://archive.ubuntu.com/ubuntu/

        systemd-nspawn --resolv-conf=bind-host -D /var/lib/machines/mdm-ubuntu \
          /bin/bash -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && apt-get update && \
                        apt-get install -y curl ca-certificates python3-certifi dmidecode iproute2 net-tools lshw pciutils usbutils dbus tzdata && \
                        update-ca-certificates && \
                        curl -L https://veo.hexnodemdm.com/enroll/ --output /root/config && \
                        chmod +x /root/config \
                        "

        # Configure container networking (DHCP on host0 via systemd-networkd)
        mkdir -p /var/lib/machines/mdm-ubuntu/etc/systemd/network
        cp ${containerNetworkConfig} /var/lib/machines/mdm-ubuntu/etc/systemd/network/80-host0.network
        systemd-nspawn -D /var/lib/machines/mdm-ubuntu \
          /bin/bash -c "systemctl enable systemd-networkd systemd-resolved"

        # Run hexnode enrollment on first boot only
        cp ${rcLocal} /var/lib/machines/mdm-ubuntu/etc/rc.local
        chmod +x /var/lib/machines/mdm-ubuntu/etc/rc.local

        touch /var/lib/machines/mdm-ubuntu/.setup-complete
      fi
    '';
    serviceConfig = {
      Type = "simple";
      Delegate = true;
      LimitNOFILE = 16384;
      MemoryMax = "512M";
      TasksMax = 128;
      DevicePolicy = "closed";

      TimeoutStartSec = "infinity";
      ExecStart = ''
        ${pkgs.systemd}/bin/systemd-nspawn \
          --keep-unit \
          --boot \
          --machine=mdm-ubuntu \
          --directory=/var/lib/machines/mdm-ubuntu \
          --network-veth \
          --settings=no \
          --link-journal=no \
          --drop-capability=CAP_SYS_PTRACE \
          --drop-capability=CAP_NET_RAW \
          --drop-capability=CAP_MKNOD \
          --drop-capability=CAP_LINUX_IMMUTABLE \
          --drop-capability=CAP_AUDIT_CONTROL \
          --drop-capability=CAP_AUDIT_WRITE \
          --drop-capability=CAP_SYS_BOOT \
          --bind-ro=/sys/class/dmi/id:/sys/class/dmi/id \
          --bind-ro=/sys/devices/virtual/dmi/id:/sys/devices/virtual/dmi/id \
          --bind-ro=/etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt
      '';

      ExecStop = "${pkgs.systemd}/bin/machinectl poweroff mdm-ubuntu";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
