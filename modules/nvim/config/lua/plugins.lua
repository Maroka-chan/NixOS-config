local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()


local packer = require('packer')

-- Recompile if plugins.lua has changed
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])


packer.startup(function(use)
  -- Let Packer manage itself
  use 'wbthomason/packer.nvim'

  -- Helper Functions
  use 'nvim-lua/plenary.nvim'

  -- Theme & Icons
  local tokyonight = { 'folke/tokyonight.nvim',
    branch = 'main',
    config = function() require('tokyonight-config').setup() end
  }
  use(tokyonight)

  -- File Tree
  use { 'kyazdani42/nvim-tree.lua',
    config = function()
      local config = require('nvim-tree-config')
      config.setup()
      config.setup_keybindings()
    end,
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- Status Line
  use { 'nvim-lualine/lualine.nvim',
    config = function() require('nvim-lualine-config').setup() end,
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- KNAP - Auto Refresh Preview for LaTeX, Markdown, HTML etc.
  use { 'frabjous/knap',
    config = function()
      local config = require('knap-config')
      config.setup()
      config.setup_keybindings()
    end
  }

  -- LSP - Language Server Protocol
  use { 'neovim/nvim-lspconfig',
    config = function () require('nvim-lspconfig-config').setup() end,
    requires = { 'hrsh7th/cmp-nvim-lsp' }
  }

  -- Folding
  use { 'kevinhwang91/nvim-ufo',
    config = function()
      local config = require('nvim-ufo-config')
      config.setup()
      config.setup_keybindings()
    end,
    requires = 'kevinhwang91/promise-async'
  }

  -- Code Snippets
  use 'rafamadriz/friendly-snippets'
  use { 'L3MON4D3/LuaSnip', tag = "v1.*",
    config = function() require('luasnip-config').setup() end
  }

  -- Code Completion
  use { 'hrsh7th/nvim-cmp',
    config = function() require('nvim-cmp-config').setup() end,
    requires = {
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-cmdline' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
      { 'L3MON4D3/LuaSnip', tag = "v<CurrentMajor>.*" },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'lukas-reineke/cmp-rg' }
    }
  }

  use { 'windwp/nvim-autopairs',
    config = function() require('nvim-autopairs-config').setup() end,
    requires = { 'hrsh7th/nvim-cmp' }
  }

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter',
    config = function () require('nvim-treesitter-config').setup() end,
    run = ':TSUpdate',
    requires = {
      { 'nvim-treesitter/nvim-treesitter-context',
        config = function () require('nvim-treesitter-context-config').setup() end
      },
      { 'nvim-treesitter/nvim-treesitter-refactor' }
    }
  }

  -- Fuzzy Finder
  use { 'nvim-telescope/telescope.nvim', tag = '0.1.0',
    config = function () require('telescope-config').setup_keybindings() end,
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    }
  }

  -- Effects
  use { 'folke/twilight.nvim',
    config = function() require("twilight-config").setup() end
  }

  -- Search
  local hlslens = { 'kevinhwang91/nvim-hlslens',
    config = function() require('nvim-hlslens-config').setup_keybindings() end
  }
  use(hlslens)

  -- Scrolling
  use { 'karb94/neoscroll.nvim',
    config = function() require('neoscroll').setup({ cursor_scrolls_alone = true }) end
  }

  -- Scrollbar
  use { 'petertriho/nvim-scrollbar',
    config = function()
      -- Set up tokyonight colors for scrollbar
      local colors = require('tokyonight.colors').setup()
      require('scrollbar').setup({
        handle = {
            color = colors.bg_highlight,
        },
        marks = {
            Search = { color = colors.orange },
            Error = { color = colors.error },
            Warn = { color = colors.warning },
            Info = { color = colors.info },
            Hint = { color = colors.hint },
            Misc = { color = colors.purple },
        }
      })
      -- Set up hlslens integration
      require('scrollbar.handlers.search').setup({ calm_down = true, nearest_only = true })
    end,
    requires = { hlslens, tokyonight }
  }


  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)
