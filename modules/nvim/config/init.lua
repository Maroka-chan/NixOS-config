-- Disable built-in plugins
-- Disable netrwPlugin for nvim-tree
vim.g.loaded              = 1
vim.g.loaded_netrwPlugin  = 1

-- Set Vim Options
local options = vim.opt

options.tabstop       = 2
options.shiftwidth    = 2
options.updatetime    = 750
options.autoindent    = true
options.autoread      = true
options.ignorecase    = true
options.smartcase     = true
options.expandtab     = true
options.number        = true
options.termguicolors = true
options.mouse         = 'nvi'
options.signcolumn    = 'yes'
options.clipboard     = 'unnamedplus'
