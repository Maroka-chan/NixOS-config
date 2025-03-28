{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
  
  # Enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
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
