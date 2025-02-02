vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/tree-sitter')

local options = {
  ensure_installed = { "lua", "vue" },

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },
  parser_install_dir = vim.fn.stdpath('data') .. '/tree-sitter',
}

return options
