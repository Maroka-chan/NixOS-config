{ lib, pkgs, config, ... }:
with lib;
let
  serviceName = "customNeovim";
  cfg = config.programs."${serviceName}";

  myConfig = pkgs.vimUtils.buildVimPlugin {
    name = "my-config";
    src = ./config;
  };

  myNeovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        luafile ${./config/init.lua}
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          myConfig

          nvim-tree-lua         # File Tree
          tokyonight-nvim       # Theme
          lualine-nvim          # Status Line
          plenary-nvim          # Lua Helper Functions
          nvim-hlslens          # Match Enhancement
          nvim-ufo              # Folding
          nvim-scrollbar        # Scrollbar
          neoscroll-nvim        # Smooth Scrolling
          nvim-web-devicons     # Icons
          twilight-nvim         # Dimming
          copilot-lua           # Copilot AI
          markdown-preview-nvim # Markdown Preview
          vimtex                # LaTeX Support
          haskell-tools-nvim    # Better Haskell Support
          neotest               # Testing Framework
          vim-csharp            # Extends CSharp support

          # Neotest Adapters
          neotest-dotnet

          # Fuzzy Finder
          telescope-nvim
          telescope-fzf-native-nvim

          # LSP
          nvim-lspconfig
          
          # Completion
          nvim-cmp
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-nvim-lsp-document-symbol
          cmp-path
          cmp-buffer
          cmp-cmdline
          cmp_luasnip
          cmp-rg
          cmp-omni
          nvim-autopairs

          # Snippets
          luasnip
          friendly-snippets

          # Parsing
          nvim-treesitter.withAllGrammars
          nvim-treesitter-context
          nvim-treesitter-refactor
        ];
        opt = [];
      };
    };
  };
in
{
  options.programs."${serviceName}" = {
    enable = mkEnableOption "Custom Neovim";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = { EDITOR = "nvim"; };

    home.packages = with pkgs; [
      myNeovim # My Configuration

      # Language Servers
      nodePackages.bash-language-server
      dockerfile-language-server-nodejs
      docker-compose-language-service
      #haskell-language-server  # Needs to be the exact same version as ghc, so it might be best to just let devenv install the language servers?
      nodePackages.pyright
      lua-language-server
      csharp-ls
      erlang-ls
      texlab
      gopls
      libclang
      rust-analyzer
      ccls

      nodejs  # Used by Copilot

      # TeX Packages
      (texlive.combine { inherit (texlive) scheme-medium latexmk biber
        pdfpages pdflscape
        minted
        lipsum
        a4wide
        tocloft
        titlesec
        biblatex; })
    
      python311Packages.pygments  # Used by minted

      # Dependencies
      ripgrep
      fd
      gcc
      tree-sitter
    ];
  };
}
