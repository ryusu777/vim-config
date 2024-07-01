local dap = require("dap")

dap.adapters.coreclr = {
  type = "executable",
  command = "netcoredbg",
  args = {"--interpreter=vscode"}
}

dap.configurations.cs = {
  {
    name = "Launch",
    type = "coreclr",
    request = "launch",
    program = function()
      return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
    console = "internalConsole"
  },
  {
    name = "Attach to process",
    type = "coreclr",
    request = "attach",
    processId = function()
      return vim.fn.input("Process Id ", "")
    end,
  }
}
