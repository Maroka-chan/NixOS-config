{
  inputs,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ../../modules/hardware/gpu/intel.nix
  ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  nix.settings.trusted-users = [username];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Needed for Noctalia to detect battery.
  services.upower.enable = true;

  # Users
  age.secrets.v00334-password.file = ../../secrets/v00334-password.age;
  users.users.${username} = {
    hashedPasswordFile = config.age.secrets."v00334-password".path;
    #extraGroups = [ "podman" ];
  };

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
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

  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.githubUsername = "Maroka-chan";
  desktops.niri.avatarHash = "sha256-gr/MY41IW26UD48sAjR778ST6LvhnZhgwKRUV8csCCY=";
  desktops.niri.extraConfig = ''
    output "eDP-1" {
        mode "1920x1200@60.0"
        transform "normal"
        scale 1.0
        position x=-1920 y=120
    }

    output "Dell Inc. DELL P3425WE 9XJNY54" {
        mode "3440x1440@99.982"
        scale 1.0
        transform "normal"
        position x=0 y=0
    }
  '';

  # Git
  programs.git.config.user.signingkey = "248853075BFB7C0E";

  # Editor
  programs.neovim-monica = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Power Management
  #services.tlp = {
  #  enable = true;
  #  settings = {
  #    START_CHARGE_THRESH_BAT0 = 20;
  #    STOP_CHARGE_THRESH_BAT0 = 80;
  #    CPU_BOOST_ON_AC = 1;
  #    CPU_BOOST_ON_BAT = 1;
  #    CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #  };
  #};

  #services.logind.lidSwitch = "suspend";
  #services.upower.enable = true;

  # Fingerprint Reader
  #services.fprintd = {
  #  enable = true;
  #};

  networking.firewall.interfaces."jetson+".allowedUDPPorts = [67];
  networking.networkmanager.ensureProfiles.profiles.usb-dhcp = {
    connection = {
      id = "usb-dhcp";
      type = "ethernet";
      autoconnect = true;
      multi-connect = "3";
    };
    match = {
      driver = "cdc_ether";
      interface-name = "jetson*";
    };
    ipv4 = {
      method = "shared";
    };
  };

  #systemd.services."usb-dhcp@" = {
  #  description = "USB DHCP for %i";
  #  after = ["network.target"];
  #  bindsTo = ["sys-subsystem-net-devices-%i.device"];

  #  serviceConfig = {
  #    Type = "forking";
  #    RuntimeDirectory = "usb-dhcp-%i";

  #    ExecStart = "${pkgs.writeShellApplication {
  #      name = "usb-dhcp-add";
  #      runtimeInputs = with pkgs; [dnsmasq iproute2 iptables procps logger];
  #      text = ''
  #        IFACE="$1"
  #        HOST_IP="10.1.42.1"
  #        CLIENT_IP="10.1.42.100"
  #        MASK="255.255.255.0"
  #        LEASE_TIME="1h"

  #        log() { logger -t usb-dhcp "$@"; }

  #        log "Interface $IFACE appeared, starting DHCP"

  #        # Kill any previous instance for this interface
  #        pkill -f "dnsmasq.*--interface=$IFACE" || true
  #        sleep 1

  #        ip addr replace "$HOST_IP/24" dev "$IFACE"
  #        ip link set "$IFACE" up
  #        iptables -I INPUT -i "$IFACE" -p udp --dport 67 -j ACCEPT

  #        dnsmasq --no-resolv --no-hosts \
  #          --port=0 \
  #          --interface="$IFACE" \
  #          --bind-interfaces \
  #          --dhcp-authoritative \
  #          --dhcp-range="$CLIENT_IP,$CLIENT_IP,$MASK,$LEASE_TIME" \
  #          --dhcp-leasefile=/run/usb-dhcp-"$IFACE"/leases

  #        log "dnsmasq started on $IFACE"
  #      '';
  #    }}/bin/usb-dhcp-add %i";

  #    ExecStop = "${pkgs.writeShellApplication {
  #      name = "usb-dhcp-remove";
  #      runtimeInputs = with pkgs; [dnsmasq iproute2 iptables procps];
  #      text = ''
  #        IFACE="$1"
  #        HOST_IP="10.1.42.1"

  #        log() { logger -t usb-dhcp "$@"; }
  #        log "Interface $IFACE removed, cleaning up"

  #        pkill -f "dnsmasq.*--interface=$IFACE" || true
  #        ip addr del "$HOST_IP/24" dev "$IFACE" 2>/dev/null || true
  #        iptables -D INPUT -i "$IFACE" -p udp --dport 67 -j ACCEPT 2>/dev/null || true
  #      '';
  #    }}/bin/usb-dhcp-remove $i";
  #  };
  #};

  # Udev rules
  ## Brightness
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"

    # FTDI
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6011", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6001", MODE="0666"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="0666"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666"

    # Jetson
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}=="7c18", MODE="0666"
    SUBSYSTEM=="net", ACTION=="add", ENV{ID_USB_DRIVER}=="cdc_ether", ENV{ID_USB_VENDOR}=="NVIDIA", ENV{ID_USB_MODEL}=="Linux_for_Tegra", NAME="jetson%n"

  '';
  #  # Ethernet over USB
  #  ACTION=="add", SUBSYSTEM=="net", DRIVERS=="cdc_ether", TAG+="systemd", ENV{SYSTEMD_WANTS}="usb-dhcp@%k.service"

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
