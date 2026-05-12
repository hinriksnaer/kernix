return {
  'mrjones2014/smart-splits.nvim',
  lazy = false, -- must load eagerly to set @pane-is-vim for tmux integration
  opts = {
    -- Ignored buffer types (only while resizing)
    ignored_buftypes = { 'nofile', 'quickfix', 'prompt' },
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = { 'NvimTree' },
    -- Resize amount (3 is faster than default 2)
    default_amount = 3,
    -- Wrap to opposite side when at edge (or 'split' to create new split)
    at_edge = 'wrap',
    -- Cursor follows buffer on swap (matches tmux swap-pane behavior)
    cursor_follows_swapped_bufs = true,
    -- Enable tmux integration
    -- This allows seamless navigation between vim and tmux
    multiplexer_integration = 'tmux',
  },
  config = function(_, opts)
    require('smart-splits').setup(opts)

    local splits = require('smart-splits')

    -- ── Unified navigation grammar (matches tmux, see tmux/default.nix) ──
    -- Alt + hjkl       = Navigate (bare)
    -- Alt + Ctrl + hjkl = Swap    (Ctrl = exchange)
    -- Alt + Shift + HJKL = Resize  (Shift = resize)

    -- Navigate: Alt + hjkl (cross-layer, seamless vim <-> tmux)
    vim.keymap.set('n', '<M-h>', splits.move_cursor_left, { desc = 'Move to left window' })
    vim.keymap.set('n', '<M-j>', splits.move_cursor_down, { desc = 'Move to lower window' })
    vim.keymap.set('n', '<M-k>', splits.move_cursor_up, { desc = 'Move to upper window' })
    vim.keymap.set('n', '<M-l>', splits.move_cursor_right, { desc = 'Move to right window' })

    -- Swap: Alt + Ctrl + hjkl (cross-layer, cursor follows buffer)
    vim.keymap.set('n', '<M-C-h>', splits.swap_buf_left, { desc = 'Swap buffer left' })
    vim.keymap.set('n', '<M-C-j>', splits.swap_buf_down, { desc = 'Swap buffer down' })
    vim.keymap.set('n', '<M-C-k>', splits.swap_buf_up, { desc = 'Swap buffer up' })
    vim.keymap.set('n', '<M-C-l>', splits.swap_buf_right, { desc = 'Swap buffer right' })

    -- Resize: Alt + Shift + HJKL (cross-layer)
    vim.keymap.set('n', '<M-H>', splits.resize_left, { desc = 'Resize split left' })
    vim.keymap.set('n', '<M-J>', splits.resize_down, { desc = 'Resize split down' })
    vim.keymap.set('n', '<M-K>', splits.resize_up, { desc = 'Resize split up' })
    vim.keymap.set('n', '<M-L>', splits.resize_right, { desc = 'Resize split right' })
  end,
}
