local autopairs     = require("nvim-autopairs")
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

local configuration = {}


autopairs.setup(configuration)

local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)
