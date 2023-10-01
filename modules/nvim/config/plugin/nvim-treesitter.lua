local treesitter_configs = require('nvim-treesitter.configs')

local parsers_to_install = {
  "bash",
  "bibtex",
  "c",
  "c_sharp",
  "cmake",
  "comment",
  "cpp",
  "css",
  "dockerfile",
  "gitignore",
  "go",
  "gomod",
  "gowork",
  "help",
  "html",
  "java",
  "javascript",
  "json",
  "latex",
  "lua",
  "make",
  "markdown",
  "python",
  "regex",
  "scss",
  "sql",
  "typescript",
  "yaml"
}

local configuration = {
  ensure_installed = {}, -- Installed through NixOS
  sync_install = false,
  auto_install = false,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },

  refactor = {
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "grr"
      }
    },
    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "gnd",
        list_definitions = "gnD",
        list_definitions_toc = "gO",
        goto_next_usage = "<a-*>",
        goto_previous_usage = "<a-#>",
      },
    }
  }
}


-- Setup
treesitter_configs.setup(configuration)
