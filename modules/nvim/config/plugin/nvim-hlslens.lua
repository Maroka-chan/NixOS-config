local hlslens = require('hlslens')


-- Setup
local kmap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

kmap('n', 'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    opts)
kmap('n', 'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    opts)
kmap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
kmap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
kmap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
kmap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)

kmap('n', '<Leader>l', ':noh<CR>', opts)


-- Try to integrate with nvim-ufo
local status, ufo = pcall(require, 'ufo')
if status then
  function _G.nN(c)
      local ok, msg = pcall(vim.cmd, 'norm!' .. vim.v.count1 .. c)
      if not ok then
          vim.api.nvim_echo({{msg:match(':(.*)$'), 'ErrorMsg'}}, false, {})
          return
      end
      hlslens.start()
      ufo.peekFoldedLinesUnderCursor()
  end
  vim.api.nvim_set_keymap('n', 'n', '<Cmd>lua _G.nN("n")<CR>', {})
  vim.api.nvim_set_keymap('n', 'N', '<Cmd>lua _G.nN("N")<CR>', {})
end
