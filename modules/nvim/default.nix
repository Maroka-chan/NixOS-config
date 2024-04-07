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

          citruszest-nvim
          #tokyonight-nvim       # Theme

          nvim-tree-lua         # File Tree
          lualine-nvim          # Status Line
          plenary-nvim          # Lua Helper Functions
          nvim-hlslens          # Match Enhancement
          #nvim-ufo              # Folding
          nvim-scrollbar        # Scrollbar
          #neoscroll-nvim        # Smooth Scrolling
          nvim-web-devicons     # Icons
          #twilight-nvim         # Dimming
          markdown-preview-nvim # Markdown Preview
          #vimtex                # LaTeX Support
          #haskell-tools-nvim    # Better Haskell Support
          neotest               # Testing Framework
          #vim-csharp            # Extends CSharp support
          #rustaceanvim

          # Neotest Adapters
          #neotest-dotnet

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
      nodePackages.pyright
      lua-language-server
      #csharp-ls
      #erlang-ls
      #texlab
      #gopls
      #libclang
      rust-analyzer
      #ccls

      lua54Packages.jsregexp # Needed by luasnip for placeholder-transformations

      # TeX Packages
     # (texlive.combine { inherit (texlive) scheme-medium latexmk biber
     #   pdfpages pdflscape
     #   minted
     #   lipsum
     #   a4wide
     #   tocloft
     #   titlesec
     #   biblatex; })
    
     # python311Packages.pygments  # Used by minted

      # Dependencies
      ripgrep
      fd
      gcc
      tree-sitter
    ];

    # Start ra-multiplex to share and persist rust-analyzer
    systemd.user.services.ra-multiplex = let
      ra-multiplex = pkgs.callPackage pkgs.rustPlatform.buildRustPackage rec {
        pname = "ra-multiplex";
        version = "0.2.3";

        src = pkgs.fetchFromGitHub {
          owner = "pr2502";
          repo = "ra-multiplex";
          rev = "v${version}";
          sha256 = "sha256-czqS6KN/K6FiGczcYKFfqkF8io8GAYZnpGLgKBXNjx0=";
        };

        cargoLock = {
          lockFile = "${src}/Cargo.lock";
          allowBuiltinFetchGit = true;
        };

        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];

        buildInputs = with pkgs; [
          pkg-config
          openssl
        ];
        
        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

        postInstall = ''
          wrapProgram "$out/bin/${pname}" \
            --prefix PATH : ${lib.makeBinPath [ pkgs.rust-analyzer pkgs.cargo ]}
        '';
      };
    in {
      Unit.Description = "Multiplex server for rust-analyzer";
      Install.WantedBy = [ "default.target" ];

      Service = {
        Type = "simple";
        ExecStart = "${ra-multiplex}/bin/ra-multiplex server";
      };
    };
  };
}
