local kmap    = vim.keymap.set

kmap('n','<leader>ll', function() vim.api.nvim_command('MarkdownPreviewToggle') end, { noremap = true })
