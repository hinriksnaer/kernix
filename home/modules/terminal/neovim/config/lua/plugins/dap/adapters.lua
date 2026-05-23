-- DAP Adapter Configurations
-- Defines debug adapters for various languages/debuggers

local M = {}
local which = require('plugins.dap.utils').which

function M.setup(dap)
  local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
  local py = which('python3') or which('python') or 'python'

  -- Python debugger (debugpy)
  dap.adapters.python = {
    type = 'executable',
    command = py,
    args = { '-m', 'debugpy.adapter' },
  }

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
