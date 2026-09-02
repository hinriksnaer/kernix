-- Neotest -- test runner framework with inline results and DAP integration
-- Run/debug individual tests, files, or suites from within Neovim.

return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-treesitter/nvim-treesitter',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-neotest/neotest-python',
  },
  keys = {
    -- Run
    { '<leader>tt', function() require('neotest').run.run() end, desc = 'Run nearest test' },
    { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run test file' },
    { '<leader>ta', function() require('neotest').run.run(vim.fn.getcwd()) end, desc = 'Run all tests' },
    { '<leader>tl', function() require('neotest').run.run_last() end, desc = 'Re-run last test' },

    -- Debug
    { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug nearest test' },
    { '<leader>tD', function() require('neotest').run.run({ vim.fn.expand('%'), strategy = 'dap' }) end, desc = 'Debug test file' },

    -- Results / UI
    { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Toggle summary' },
    { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = 'Show output' },
    { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle output panel' },

    -- Navigation
    { '[t', function() require('neotest').jump.prev({ status = 'failed' }) end, desc = 'Previous failed test' },
    { ']t', function() require('neotest').jump.next({ status = 'failed' }) end, desc = 'Next failed test' },

    -- Stop
    { '<leader>tS', function() require('neotest').run.stop() end, desc = 'Stop test run' },
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-python')({
          dap = { justMyCode = false },
          runner = 'pytest',
          args = { '-s', '--no-header', '-rN' },
        }),
      },
      status = {
        virtual_text = true,
      },
      output = {
        open_on_run = false,
      },
    })
  end,
}
