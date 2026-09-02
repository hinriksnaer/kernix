-- Diffview -- side-by-side diffs, file history, branch comparison
-- Opens a clean side-by-side view (file panel hidden by default, toggle with <leader>b).

local function toggle_diffview()
  local lib = require 'diffview.lib'
  if lib.get_current_view() then
    vim.cmd 'DiffviewClose'
  else
    vim.cmd 'DiffviewOpen'
  end
end

return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles' },
  keys = {
    { '<leader>gd', toggle_diffview, desc = 'Toggle diff view' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'File history' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = 'Repo history' },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = 'diff2_horizontal',
        disable_diagnostics = true,
        winbar_info = true,
      },
      merge_tool = {
        layout = 'diff3_mixed',
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        layout = 'diff2_horizontal',
        disable_diagnostics = true,
        winbar_info = true,
      },
    },
    hooks = {
      view_opened = function()
        -- Hide the file panel for a clean side-by-side view.
        -- Press <leader>b inside diffview to bring it back.
        require('diffview.actions').toggle_files()
      end,
      diff_buf_read = function()
        -- Reduce visual clutter in diff buffers
        vim.opt_local.wrap = false
        vim.opt_local.list = false
        vim.opt_local.colorcolumn = {}
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
      end,
    },
  },
}
