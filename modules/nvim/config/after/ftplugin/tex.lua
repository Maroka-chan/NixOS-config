-- Completion Formatting
require('cmp').setup.buffer {
  formatting = {
    format = function(entry, vim_item)
        vim_item.menu = ({
          omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
          luasnip = "[LuaSnip]",
          buffer = "[Buffer]",
          })[entry.source.name]
        return vim_item
      end,
  },
  sources = {
    { name = 'omni' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
}
