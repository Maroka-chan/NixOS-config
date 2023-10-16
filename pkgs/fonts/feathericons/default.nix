{ lib, stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation {
  pname = "feathericons";
  version = "5-8-2018";

  src = fetchFromGitHub {
    owner = "AT-UI";
    repo = "feather-font";
    rev = "c51fe7cedbcf2cbf4f1b993cef5d8def612dec1d";
    hash = "sha256-UjwbWOxal+8R6kTz3kxsTqUiuuJ2fA3aNBJATeUSYUI=";
  };

  installPhase = ''
    runHook preInstall

    install -m444 -Dt $out/share/fonts/truetype src/fonts/*.ttf

    runHook postInstall
  '';

  meta = with lib; {
    description = "Feather Icons - TTF font";
    longDescription = ''
      Simply beautiful open source icons
    '';
    homepage = "https://feathericons.com/";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ Maroka-chan ];
  };
}
