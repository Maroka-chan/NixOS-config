{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "fot-yuruka";
  version = "1.0";

  src = ./. + "/fot-yuruka_std.ttf";

  unpackPhase = ''
   install -Dm644 $src -t $out/share/fonts/truetype
  '';

  dontConfigure = true;
  dontBuild = true;
  dontInstall = true;
}
