{pkgs, ...}: {
  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  # Enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/jellyfin"
    ];
  };
}
