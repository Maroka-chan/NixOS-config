{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Work around hard-coded HIP libraries
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
}
