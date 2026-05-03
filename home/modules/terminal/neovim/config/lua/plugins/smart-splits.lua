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

    -- Navigation that works seamlessly with tmux
    -- These replace the existing Ctrl+hjkl mappings
    vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left, { desc = 'Move to left window' })
    vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down, { desc = 'Move to lower window' })
    vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up, { desc = 'Move to upper window' })
    vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right, { desc = 'Move to right window' })

    -- Note: Alt+hjkl reserved for tmux navigation layer (see tmux/default.nix)
  end,
}
