local dap = require("dap")
local dapui = require("dapui")

-- DAP UI setup
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Use this to override the default layouts
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
    },
  },
})

-- Automatically open/close DAP UI when debugging starts/ends
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.adapters.docker_netcoredbg = function(callback, config)
  callback({
    type = 'executable',
    command = 'docker-compose',
    args = { 
      'exec',
      config.service_name,
      '/netcoredbg/netcoredbg',
      '--interpreter=vscode' 
    }
  })
end

dap.adapters.server = {
  type = 'server',
  port = 4711
}

dap.adapters.coreclr = function(callback, config)
  callback({
    type = 'executable',
    command = '/usr/local/netcoredbg/netcoredbg',
    args = { '--interpreter=vscode' }
  })
end

-- Add server configuration
dap.configurations.cs = {
  {
    name = "Attach to process",
    type = "coreclr",
    request = "attach",
    processId = function()
      return vim.fn.input('Process Id: ')
    end
  },
  {
    name = "Launch",
    type = "coreclr",
    request = "launch",
    program = function()
      local projectName = vim.fn.input('Project Name: ')
      local fileName = "${workspaceFolder}/".. projectName .. "/bin/Debug/net8.0/" .. projectName .. ".dll"
      return fileName
    end
  },
  {
    name = "Docker Compose",
    type = "docker_netcoredbg",
    request = "attach",
    processId = "1",
    service_name = function()
      return vim.fn.input('Service name: ')
    end
  },
}

-- DAP Keymap
vim.keymap.set('n', '<F5>', function() dap.continue() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
vim.keymap.set('n', '<Leader>b', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)
vim.keymap.set('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end)

-- DAP UI Keymaps
vim.keymap.set('n', '<Leader>du', function() dapui.toggle() end)
vim.keymap.set('n', '<Leader>de', function() dapui.eval() end)
vim.keymap.set('n', '<Leader>dE', function() dapui.eval(vim.fn.input('[Expression] > ')) end)
