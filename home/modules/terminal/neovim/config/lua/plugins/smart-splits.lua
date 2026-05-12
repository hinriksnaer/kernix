return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  opts = {
    -- Ignored buffer types (only while resizing)
    ignored_buftypes = { 'nofile', 'quickfix', 'prompt' },
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = { 'NvimTree' },
    -- Resize amount (3 is faster than default 2)
    default_amount = 3,
    -- Wrap to opposite side when at edge (or 'split' to create new split)
    at_edge = 'wrap',
    -- Enable tmux integration
    -- This allows seamless navigation between vim and tmux
    multiplexer_integration = 'tmux',
  },
  config = function(_, opts)
    require('smart-splits').setup(opts)

    local splits = require('smart-splits')

    -- Navigate (Alt+hjkl): cross-layer, seamless vim <-> tmux
    vim.keymap.set('n', '<M-h>', splits.move_cursor_left, { desc = 'Move to left window' })
    vim.keymap.set('n', '<M-j>', splits.move_cursor_down, { desc = 'Move to lower window' })
    vim.keymap.set('n', '<M-k>', splits.move_cursor_up, { desc = 'Move to upper window' })
    vim.keymap.set('n', '<M-l>', splits.move_cursor_right, { desc = 'Move to right window' })

    -- Resize (Ctrl+arrows): intuitive directional resize
    vim.keymap.set('n', '<C-Left>', splits.resize_left, { desc = 'Resize split left' })
    vim.keymap.set('n', '<C-Down>', splits.resize_down, { desc = 'Resize split down' })
    vim.keymap.set('n', '<C-Up>', splits.resize_up, { desc = 'Resize split up' })
    vim.keymap.set('n', '<C-Right>', splits.resize_right, { desc = 'Resize split right' })

    -- Swap bindings are in config/keymaps.lua under <leader>w
  end,
}
