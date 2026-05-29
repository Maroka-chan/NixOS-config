{pkgs, ...}: let
  name = "mdm-ubuntu";
  veth = "ve-${name}";
in {
  # Host-side veth for hexnode MDM container
  networking.networkmanager.ensureProfiles.profiles.${veth} = {
    connection = {
      id = veth;
      type = "ethernet";
      interface-name = veth;
      autoconnect = "true";
    };
    ipv4 = {
      method = "shared";
      address1 = "10.0.100.1/24";
      never-default = "true";
      ignore-auto-routes = "true";
      ignore-auto-dns = "true";
      may-fail = "false";
    };
    ipv6 = {
      method = "disabled";
    };
  };

  # Hexnode MDM container
  systemd.services."${name}-container" = let
    rcLocal = pkgs.writeScript "rc.local" ''
      #!/bin/bash
      # Wait for network (host-side NM profile may not be up yet)
      until getent hosts veo.hexnodemdm.com &>/dev/null; do
        sleep 2
      done

      if [ ! -f /root/.enrolled ]; then
        /root/config && touch /root/.enrolled
      fi
    '';
    containerNetworkConfig = pkgs.writeText "80-host0.network" ''
      [Match]
      Name=host0

      [Network]
      DHCP=ipv4
      LinkLocalAddressing=ipv4
      IPv6AcceptRA=no
    '';
    machineDir = "/var/lib/machines/${name}";
  in {
    description = "Ubuntu 24.04 Container for Hexnode MDM";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    path = with pkgs; [debootstrap systemd bash coreutils];

    preStart = ''
      mkdir -p ${machineDir}

      if [ ! -f ${machineDir}/.setup-complete ]; then
        rm -rf ${machineDir}/
        echo "Bootstrapping Ubuntu 24.04 (Noble)... This may take a few minutes."
        debootstrap noble ${machineDir} http://archive.ubuntu.com/ubuntu/

        systemd-nspawn --resolv-conf=bind-host -D ${machineDir} \
          /bin/bash -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && apt-get update && \
                        apt-get install -y curl ca-certificates python3-certifi dmidecode iproute2 net-tools lshw pciutils usbutils dbus tzdata && \
                        update-ca-certificates && \
                        curl -L https://veo.hexnodemdm.com/enroll/ --output /root/config && \
                        chmod +x /root/config \
                        "

        # Enable systemd-networkd inside the container
        mkdir -p ${machineDir}/etc/systemd/system/multi-user.target.wants
        ln -sf /lib/systemd/system/systemd-networkd.service ${machineDir}/etc/systemd/system/multi-user.target.wants/systemd-networkd.service

        # Configure host0 inside the container (IPv4 DHCP, no IPv6)
        mkdir -p ${machineDir}/etc/systemd/network
        cp ${containerNetworkConfig} ${machineDir}/etc/systemd/network/80-host0.network

        # Run hexnode enrollment on first boot only
        cp ${rcLocal} ${machineDir}/etc/rc.local
        chmod +x ${machineDir}/etc/rc.local

        touch ${machineDir}/.setup-complete
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
          --machine=${name} \
          --directory=${machineDir} \
          --network-veth \
          --settings=no \
          --link-journal=no \
          --drop-capability=CAP_SYS_PTRACE \
          --drop-capability=CAP_MKNOD \
          --drop-capability=CAP_LINUX_IMMUTABLE \
          --drop-capability=CAP_AUDIT_CONTROL \
          --drop-capability=CAP_AUDIT_WRITE \
          --drop-capability=CAP_SYS_BOOT \
          --bind-ro=/sys/class/dmi/id:/sys/class/dmi/id \
          --bind-ro=/sys/devices/virtual/dmi/id:/sys/devices/virtual/dmi/id \
      '';

      ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.iproute2}/bin/ip link show ${veth} &>/dev/null; do sleep 0.5; done; ${pkgs.networkmanager}/bin/nmcli connection up ${veth}'";
      ExecStop = "${pkgs.systemd}/bin/machinectl poweroff ${name}";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
