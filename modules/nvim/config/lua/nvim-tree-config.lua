local nvimtree = require('nvim-tree')

local configuration = {
  sort_by = "case_sensitive",
  hijack_cursor = true,
  diagnostics = {
    enable = true
  },
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
    highlight_opened_files = "all",
    indent_markers = {
      enable = true
    }
  },
  filters = {
    dotfiles = true,
  },
  actions = {
    open_file = {
      quit_on_open = true
    }
  }
}

-- Setup
nvimtree.setup(configuration)

-- Keymappings
vim.keymap.set('n', '<M-TAB>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
