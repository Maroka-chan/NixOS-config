local knap = require('knap')

local _engine = "tectonic"
local _flags = "--synctex --keep-logs"

local compose_cmd = function(engine, flags)
  return string.format("%s %s ", engine, flags) .. "%docroot%"
end


local gknapsettings = {
    texoutputext = "pdf",
    textopdf = compose_cmd(_engine, _flags),
    textopdfshorterror = "A=%outputfile% ; LOGFILE=\"${A%.pdf}.log\" ; rg -N ! \"$LOGFILE\" 2>&1 | head -n 1",
}


local shell_escape_enabled = false

local toggle_shell_escape = function()
  local flags = _flags

  if not shell_escape_enabled then
    flags = string.format("%s %s", flags, "-Z shell-escape-cwd=$(pwd)")
    print("shell-escape enabled")
  else print("shell-escape disabled") end

  gknapsettings.textopdf = compose_cmd(_engine, flags)
  local bsettings = vim.b.knap_settings or {}
  bsettings = vim.tbl_extend("keep", gknapsettings, bsettings)
  vim.b.knap_settings = bsettings
  shell_escape_enabled = not shell_escape_enabled
end


-- Setup
vim.g.knap_settings = gknapsettings


-- Keybindings
-- set shorter name for keymap function
local kmap = vim.keymap.set

-- F12 toggles wether the -shell-escape flag is used
kmap('n','<leader>ls', function() toggle_shell_escape() end, { noremap = true })

-- F5 processes the document once, and refreshes the view
kmap('n','<leader>ll', function() knap.process_once() end, { noremap = true })

-- F6 closes the viewer application, and allows settings to be reset
kmap('n','<leader>lc', function() knap.close_viewer() end, { noremap = true })

-- F7 toggles the auto-processing on and off
kmap('n','<leader>lk', function() knap.toggle_autopreviewing() end, { noremap = true })

-- F8 invokes a SyncTeX forward search, or similar, where appropriate
kmap('n','<leader>lg', function() knap.forward_jump() end, { noremap = true })
