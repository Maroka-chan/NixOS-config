{
  lib,
  symlinkJoin,
  rustPlatform,
  openssl,
  pkg-config,
  mpv,
  makeWrapper,
  nodejs,
  libadwaita,
  libepoxy,
  wrapGAppsHook4,
  cef-binary,
  libGL,
  fetchFromGitHub,
  windowDecor ? false,
  ...
}: let
  # Follow upstream
  # https://github.com/Stremio/stremio-linux-shell/blob/f2499ad63f28858d913e2776befbcd029900fd5f/flatpak/com.stremio.Stremio.Devel.json#L143
  cefPinned = cef-binary.override {
    version = "143.0.9";
    gitRevision = "e88e818";
    chromiumVersion = "143.0.7499.40";

    srcHashes = {
      aarch64-linux = "";
      x86_64-linux = "sha256-+UBlqf8xuriiqosQia/vUothSpSfkoupwZ1kTCkNlk8=";
    };
  };
  # cef-rs expects the files in a specific layout
  cefPath = symlinkJoin {
    name = "stremio-cef-target";
    paths = [
      "${cefPinned}/Resources"
      "${cefPinned}/Release"
    ];
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "stremio-linux-shell-rewrite";
    src = fetchFromGitHub {
      owner = "Stremio";
      repo = "stremio-linux-shell";
      #tag = "v${finalAttrs.version}";
      #branch = "refactor/gtk4";
      rev = "73c1e42323292b534b67f168987034812d5aa8b9";
      fetchSubmodules = false;
      hash = "sha256-+lB0tfzbENQfwNxaAWhLM3/Es5xdbODdyOxsR7AxnLU=";
    };
    version = "0-unstable-${builtins.substring 0 8 finalAttrs.src.rev}";

    cargoLock = {
      lockFile = "${finalAttrs.src}/Cargo.lock";
      outputHashes = {
        # cef hash is missing because it's fetched at build time
        "cef-143.1.0+143.0.10" = "sha256-EStyjg5z3Z4GafN2chbm5TVqZOxYgy3+PbB1ZxgGghg=";
      };
    };

    buildInputs = [
      libadwaita
      libepoxy
      openssl
      mpv
    ];

    nativeBuildInputs = [
      wrapGAppsHook4
      makeWrapper
      pkg-config
    ];

    # Don't download CEF during build
    buildFeatures = ["offline-build"];
    # use packaged CEF
    env.CEF_PATH = cefPath;

    postInstall = ''
      mkdir -p $out/share/applications
      cp data/com.stremio.Stremio.desktop $out/share/applications/com.stremio.Stremio.desktop

      mkdir -p $out/share/icons/hicolor/scalable/apps
      cp data/icons/com.stremio.Stremio.svg $out/share/icons/hicolor/scalable/apps/com.stremio.Stremio.svg

      mkdir -p $out/lib/stremio
      cp data/server.js $out/lib/stremio/server.js

      mv $out/bin/stremio-linux-shell $out/bin/stremio
    '';

    # Node.js is required to run `server.js`
    # Add to `gappsWrapperArgs` to avoid two layers of wrapping.
    preFixup = ''
      gappsWrapperArgs+=(
        --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libGL]}" \
        --prefix PATH : "${lib.makeBinPath [nodejs]}" \
        --set SERVER_PATH "$out/lib/stremio/server.js" \
        ${lib.optionalString (!windowDecor) "--add-flags '--no-window-decorations'"}
      )
    '';

    meta = {
      mainProgram = "stremio";
      description = "Modern media center that gives you the freedom to watch everything you want";
      homepage = "https://github.com/Stremio/stremio-linux-shell";
      license = with lib.licenses; [
        gpl3Only
        # server.js is unfree
        unfree
      ];
      maintainers = lib.maintainers.fazzi;
      platforms = lib.platforms.linux;
    };
  })
