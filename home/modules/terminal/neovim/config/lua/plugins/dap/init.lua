-- DAP (Debug Adapter Protocol) Configuration Loader
-- Main plugin specification and module loader

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- 'rcarriga/nvim-dap-ui',
    -- 'nvim-neotest/nvim-nio',
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
  },
  config = function()
    local dap = require('dap')

    -- Load modular configurations
    require('plugins.dap.signs').setup()
    require('plugins.dap.adapters').setup(dap)
    require('plugins.dap.python').setup(dap)
    require('plugins.dap.keymaps').setup(dap)
  end,
}
