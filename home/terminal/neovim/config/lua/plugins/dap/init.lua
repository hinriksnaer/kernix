-- DAP (Debug Adapter Protocol) Configuration Loader
-- Main plugin specification and module loader

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    {
      'igorlfs/nvim-dap-view',
      opts = {
        winbar = {
          sections = { 'watches', 'scopes', 'exceptions', 'breakpoints', 'threads', 'repl', 'console' },
          default_section = 'scopes',
        },
        windows = {
          size = 0.35,
          position = 'right',
          terminal = {
            hide = { 'console' },
          },
        },
        auto_toggle = true,
      },
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
  end,
}
