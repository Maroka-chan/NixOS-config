{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Work around hard-coded HIP libraries
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocmPackages.clr.icd
  ];

  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
}
