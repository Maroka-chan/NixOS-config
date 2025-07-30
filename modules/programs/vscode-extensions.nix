{ pkgs, lib } :
{
  lakshits11.monokai-pirokai = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "monokai-pirokai";
      publisher = "lakshits11";
      version = "0.0.3";
      hash = "sha256-c5rrEqb6xzgCpbD8/rojzYtfGsPPPFl+NJ8M7m0BAZc=";
    };
    meta = {
      changelog = "https://marketplace.visualstudio.com/items/lakshits11.monokai-pirokai/changelog";
      description = "The ultimate theme that combines the vibrant colors of Monokai Pro with a sleek, dark background for maximum style and productivity";
      downloadPage = "https://marketplace.visualstudio.com/items?itemName=lakshits11.monokai-pirokai";
      homepage = "https://github.com/lakshits11/monokai-pirokai";
    };
  };
}

