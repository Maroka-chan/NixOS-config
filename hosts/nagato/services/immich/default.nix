{...}: {
  # -- NFS mount for Immich media from TrueNAS --
  boot.supportedFilesystems = ["nfs"];

  fileSystems."/mnt/immich" = {
    device = "nas.bmj:/mnt/pool/immich";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "soft"
      "timeo=150"
      "retrans=3"
      "rsize=1048576"
      "wsize=1048576"
      "_netdev"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };

  # -- Immich service --
  services.immich = {
    enable = true;
    port = 2283;
    mediaLocation = "/mnt/immich";

    # Allow access to GPU devices for CUDA ML inference and NVENC transcoding
    accelerationDevices = null;
  };

  # GPU groups for hardware-accelerated transcoding + ML
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  # Ensure Immich starts after the NFS automount is available
  systemd.services.immich-server = {
    after = ["mnt-immich.automount"];
    requires = ["mnt-immich.automount"];
  };

  # Restrict /mnt/immich mount point permissions to immich user only
  systemd.tmpfiles.rules = [
    "d /mnt/immich 0700 immich immich -"
  ];
}
