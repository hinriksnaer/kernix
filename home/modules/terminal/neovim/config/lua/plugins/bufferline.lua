-- bufferline.nvim - Visual buffer tab bar with ordinal numbering
-- Provides the Task level of the neovim navigation grammar:
--   \[/]     = cycle buffers
--   \C-[/]   = reorder buffers
--   \1-9     = jump to buffer by ordinal
-- Keymaps are defined in config/keymaps.lua with the rest of the \ layer.

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VimEnter',
  opts = {
    options = {
      numbers = 'ordinal',
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(count, level)
        local icon = level:match 'error' and '󰅚 ' or '󰀪 '
        return ' ' .. icon .. count
      end,
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = 'thin',
      always_show_bufferline = true,
      sort_by = 'insert_at_end',
      -- Close with mini.bufremove to preserve window layout
      close_command = function(bufnr)
        require('mini.bufremove').delete(bufnr)
      end,
      right_mouse_command = function(bufnr)
        require('mini.bufremove').delete(bufnr)
      end,
    },
  },
}
