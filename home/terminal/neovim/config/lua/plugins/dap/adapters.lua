-- DAP Adapter Configurations
-- Defines debug adapters for various languages/debuggers
-- Note: Python adapter (debugpy) is registered by nvim-dap-python in init.lua

local M = {}

function M.setup(dap)
  local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'

  -- C++ debugger (GDB via cpptools)
  dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = mason_bin .. '/OpenDebugAD7',
  }

  -- C++ debugger (LLDB via CodeLLDB)
  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
      args = { '--port', '${port}' },
    },
  }
end

return M
