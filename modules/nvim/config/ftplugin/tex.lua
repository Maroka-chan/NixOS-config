local globals = vim.g
local kmap    = vim.keymap.set

-- Shell Escape Toggle
local shell_escape_enabled = false

local toggle_shell_escape = function()
  local options = {
    "-verbose",
    "-file-line-error",
    "-synctex=1",
    "-interaction=nonstopmode"
  }
  local msg = "shell-escape disabled"

  if not shell_escape_enabled then
    table.insert(options, "-shell-escape")
    msg = "shell-escape enabled"
  end

  globals.vimtex_compiler_latexmk = { options = options }
  vim.api.nvim_command('VimtexReload')
  shell_escape_enabled = not shell_escape_enabled
  print(msg)
end


-- Keymappings
kmap('n','<leader>ls', function() toggle_shell_escape() end, { noremap = true })
