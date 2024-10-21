dofile(vim.g.base46_cache .. "lsp")
require "nvchad.lsp"

local M = {}
local utils = require "core.utils"
local lspUtil = require "core.lsputil"

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad.signature").setup(client)
  end

  if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

require("lspconfig").lua_ls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_dir = function(fname)
    local root = util.root_pattern(unpack(root_files))(fname)
    if root and root ~= vim.env.HOME then
      return root
    end
    local root_lua = lspUtil.root_pattern 'lua/'(fname) or ''
    local root_git = lspUtil.find_git_ancestor(fname) or ''
    return #root_lua >= #root_git and root_lua or root_git
  end,
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
}

require("lspconfig").csharp_ls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

local function get_typescript_server_path(root_dir)
  local global_ts = 'C:/inter/AppData/Roaming/npm/node_modules/node_modules/typescript/lib'
  -- Alternative location if installed as root:
  -- local global_ts = '/usr/local/lib/node_modules/typescript/lib'
  local found_ts = ''
  local function check_dir(path)
    found_ts =  lspUtil.path.join(path, 'node_modules', 'typescript', 'lib')
    if lspUtil.path.exists(found_ts) then
      return path
    end
  end
  if lspUtil.search_ancestors(root_dir, check_dir) then
    return found_ts
  else
    return global_ts
  end
end

require("lspconfig").volar.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  filetypes = { "javascript", "typescript", "vue" },
  cmd = { 'vue-language-server', '--stdio' },
  init_options = {
    vue = {
      hybridMode = false,
      enableTsInTemplate = true,
    },
    typescript = {
      tsdk = get_typescript_server_path(new_root_dir),
      takeOverMode = true,
    },
  },
  root_dir = lspUtil.root_pattern 'package.json',
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
}

return M

-- require("lspconfig").ts_ls.setup {
--   on_attach = M.on_attach,
--   capabilities = M.capabilities,
--   cmd = {"typescript-language-server", "--stdio"},
--   init_options = {
--     plugins = {
--       {
--         name = "@vue/typescript-plugin",
--         location = 'C:/Users/inter/AppData/Roaming/npm/node_modules/@vue/typescript-plugin',
--         languages = {"javascript", "typescript", "vue"}
--       }
--     }
--   },
--   filetypes = { }
-- }
