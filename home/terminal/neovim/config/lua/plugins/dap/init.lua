-- DAP (Debug Adapter Protocol) Configuration Loader
-- Main plugin specification and module loader

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'nvim-neotest/nvim-nio' },
      config = function()
        require('dapui').setup()
      end,
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      opts = {},
    },
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require('dap')
    local which = require('plugins.dap.utils').which

    -- Load modular configurations
    require('plugins.dap.signs').setup()
    require('plugins.dap.adapters').setup(dap)

    -- nvim-dap-python: registers the debugpy adapter and provides
    -- test_method()/test_class() for debugging individual tests.
    local py = which('python3') or which('python') or 'python'
    require('dap-python').setup(py)
    require('dap-python').test_runner = 'pytest'

    require('plugins.dap.python').setup(dap)
    require('plugins.dap.keymaps').setup(dap)

    local dapui = require('dapui')
    dap.listeners.before.attach['dapui_config'] = function() dapui.open() end
    dap.listeners.before.launch['dapui_config'] = function() dapui.open() end
    dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
    dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
  end,
}
