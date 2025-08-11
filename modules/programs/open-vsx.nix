{ pkgs, lib } :
{
  detachhead.basedpyright = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "basedpyright";
      publisher = "detachhead";
      version = "1.31.1";
      hash = "sha256-MlkLoM1415KYCKlwfV67HLLvmF7PRtdyQrPgeNm2nyM=";
    };
    meta = {
      changelog = "https://github.com/detachhead/basedpyright/release";
      description = "VS Code static type checking for Python (but based)";
      downloadPage = "https://github.com/detachhead/basedpyright/release";
      homepage = "https://docs.basedpyright.com";
    };
  };
  monokai.theme-monokai-pro-vscode = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "theme-monokai-pro-vscode";
      publisher = "monokai";
      version = "2.0.7";
      hash = "sha256-MRFOtadoHlUbyRqm5xYmhuw0LL0qc++gR8g0HWnJJRE=";
    };
    meta = {
      changelog = "https://open-vsx.org/extension/monokai/theme-monokai-pro-vscode/changes";
      description = "✨ Professional dark & light theme + icon pack, from the author of the original Monokai color scheme.";
      downloadPage = "https://open-vsx.org/extension/monokai/theme-monokai-pro-vscode";
      homepage = "https://monokai.pro";
    };
  };
}

