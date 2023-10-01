local ufo = require('ufo')

local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = ('  %d '):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, {chunkText, hlGroup})
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, {suffix, 'MoreMsg'})
  return newVirtText
end


local configuration = {
  open_fold_hl_timeout = 0,
  close_fold_kinds = { 'imports', 'comment' },
  preview = {
    win_config = {
      border = {'', '─', '', '', '', '─', '', ''},
      winhighlight = 'Normal:Folded',
      winblend = 0
    }
  },
  fold_virt_text_handler = handler
}


-- Setup
local opts = vim.o

opts.foldcolumn = '1'
opts.foldlevel = 99
opts.foldlevelstart = 99
opts.foldenable = true
opts.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

ufo.setup(configuration)


-- Keybindings
local kmap = vim.keymap.set

kmap('n', 'zR', ufo.openAllFolds)
kmap('n', 'zM', ufo.closeAllFolds)
kmap('n', 'zr', ufo.openFoldsExceptKinds)
kmap('n', 'zm', ufo.closeFoldsWith)
kmap('n', 'K', function()
  local winid = require('ufo').peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end)
