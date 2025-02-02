dofile(vim.g.base46_cache .. "lsp")
require "nvchad.lsp"

local M = {}
local utils = require "core.utils"
local lspUtil = require "core.lsputil"

-- export on_attach & capabilities for custom lspconfigs

M.on_init = function(client, _)
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

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
  -- First try to find typescript in the project
  local local_ts = lspUtil.path.join(root_dir, 'node_modules', 'typescript', 'lib')
  if lspUtil.path.exists(local_ts) then
    return local_ts
  end
  
  -- Then try the global installation
  local global_ts = '/usr/local/lib/node_modules/typescript/lib'
  if lspUtil.path.exists(global_ts) then
    return global_ts
  end

  -- Fallback to user's npm global directory
  return vim.fn.expand('~/.npm/lib/node_modules/typescript/lib')
end

require("lspconfig").volar.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  filetypes = { "typescript", "javascript", "vue" },
  cmd = { "vue-language-server", "--stdio" },
  root_dir = lspUtil.root_pattern("package.json", "vue.config.js", ".git"),
  init_options = {
    typescript = {
      tsdk = get_typescript_server_path(vim.fn.getcwd()),
    },
    languageFeatures = {
      implementation = true,
      references = true,
      definition = true,
      typeDefinition = true,
      callHierarchy = true,
      hover = true,
      rename = true,
      renameFileRefactoring = true,
      signatureHelp = true,
      codeAction = true,
      workspaceSymbol = true,
      completion = {
        defaultTagNameCase = "both",
        defaultAttrNameCase = "kebabCase",
        getDocumentNameCasesRequest = false,
        getDocumentSelectionRequest = false,
      },
    },
  },
  
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
