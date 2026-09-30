{lib, ...}: {
  # NVIDIA proprietary drivers
  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # Set to true for Turing+ GPUs, false for Pascal and older
    open = lib.mkDefault false;
    modesetting.enable = true;
  };
}
