{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "fot-yuruka";
  version = "1.0";

  src = ./. + "/FOT-Yuruka Std.ttf";

  #unpackPhase = ''
  #  runHook preUnpack
  #  ${pkgs.unzip}/bin/unzip $src

  #  runHook postUnpack
  #'';

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';
}
