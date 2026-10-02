{lib, ...}: {
  # NVIDIA proprietary drivers
  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # Set to true for Turing+ GPUs, false for Pascal and older
    open = lib.mkDefault false;
    modesetting.enable = true;
  };

  nixpkgs.config.cudaSupport = true;

  nixpkgs.overlays = [
    (final: prev: {
      firefox-unwrapped = prev.firefox-unwrapped.override {
        onnxruntime = prev.onnxruntime.override {cudaSupport = false;};
      };
    })
  ];

  # Binary cache for CUDA-enabled packages
  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}
