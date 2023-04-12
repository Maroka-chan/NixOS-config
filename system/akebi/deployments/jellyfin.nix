{ config, pkgs, lib, ... }:
{
    # Enable vaapi on OS-level
    nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
    hardware.opengl = {
        enable = true;
        extraPackages = with pkgs; [
            intel-media-driver
            vaapiIntel
            vaapiVdpau
            libvdpau-va-gl
            intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
        ];
    };

    systemd.services.jellyfin = {
        confinement.enable = true;
        serviceConfig = {
            ProtectSystem = false;
            # ProtectHome = true;
            # PrivateDevices = true;
            # PrivateTmp = true; # Enabled with confinement
            # PrivateNetwork = true;
            NoNewPrivileges = true;
            # ProtectDevices = true; # Unknown?
            # ProtectKernelTunables = true; # Enabled with confinement
            # ProtectKernelModules = true;  # Enabled with confinement
            # ProtectControlGroups = true;  # Enabled with confinement
            SystemCallFilter = [ "@system-service" ];
            SystemCallErrorNumber = "EPERM";
            # PrivateMounts = true; # Enabled with confinement
            # DynamicUser = true; # Not supported with confinement
            ProtectKernelLogs = true;
            # PrivateUsers = true; # Enabled with confinement
            SystemCallArchitectures = "native";
            AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
            DevicePolicy = "closed";
            RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            # RestrictSUIDSGID = true;
            # MemoryDenyWriteExecute = true;
            LockPersonality = true;
            ProtectHostname = true;
            ProtectProc = "invisible";
            CapabilityBoundingSet = "~CAP_SYS_ADMIN";
            # TemporaryFileSystem = "/:ro";
            NoExecPaths = [ "/" ];
            ExecPaths = [ "/nix/store" ];
            BindReadOnlyPaths = [
                "/data"
                "/etc/resolv.conf"
                ];
        };
    };

    services.jellyfin.enable = true;
    services.jellyfin.openFirewall = true;
}