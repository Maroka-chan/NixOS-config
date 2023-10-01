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
      lua-language-server
      csharp-ls
      nodePackages.bash-language-server
      dockerfile-language-server-nodejs
      docker-compose-language-service
      gopls
      nodePackages.pyright
      texlab
      haskell-language-server
      erlang-ls

      nodejs  # Used by Copilot

      # TeX Packages
      (texlive.combine { inherit (texlive) scheme-basic latexmk
        pdfpages pdflscape
        minted; })
    
      python311Packages.pygments  # Used by minted
    ];
  };
}
