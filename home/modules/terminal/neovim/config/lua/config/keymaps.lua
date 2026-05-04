-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
-- See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- LSP keymaps (<leader>lq is defined in lspconfig.lua via fzf-lua)
vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = 'Restart LSP' })
vim.keymap.set('n', '<leader>li', '<cmd>LspInfo<CR>', { desc = 'LSP Info' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation is handled by smart-splits.nvim plugin
-- Ctrl+hjkl works seamlessly between vim windows and tmux panes

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Note: Alt+hjkl reserved for tmux navigation layer (see tmux/default.nix)

-- Better indenting - stay in visual mode
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

-- Better paste - don't yank replaced text
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste without yanking' })

-- Window resizing available via smart-splits.nvim plugin if needed
-- Alt+hjkl reserved for tmux navigation layer

-- Better search - center screen on next/previous match
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result (centered)' })

-- Center screen on common jumps
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })

-- Buffer navigation (uses BufferLine for consistent ordering, defined below)

-- Quick switch to alternate buffer
vim.keymap.set('n', '<leader><leader>', '<cmd>e#<CR>', { desc = 'Switch to alternate buffer' })

-- Buffer management
vim.keymap.set('n', '<leader>bd', function()
  require('mini.bufremove').delete()
end, { desc = 'Delete Buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>enew<CR>', { desc = 'New buffer' })
vim.keymap.set('n', '<leader>bD', '<cmd>%bd|e#|bd#<CR>', { desc = 'Delete all buffers except current' })

-- Quickfix list navigation
vim.keymap.set('n', '<leader>qo', '<cmd>copen<CR>', { desc = 'Open quickfix' })
vim.keymap.set('n', '<leader>qc', '<cmd>cclose<CR>', { desc = 'Close quickfix' })
vim.keymap.set('n', '<leader>qn', '<cmd>cnext<CR>', { desc = 'Next quickfix item' })
vim.keymap.set('n', '<leader>qp', '<cmd>cprev<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', '[q', '<cmd>cprev<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', ']q', '<cmd>cnext<CR>', { desc = 'Next quickfix item' })

-- Location list navigation (for LSP diagnostics)
vim.keymap.set('n', '<leader>qlo', '<cmd>lopen<CR>', { desc = 'Open location list' })
vim.keymap.set('n', '<leader>qlc', '<cmd>lclose<CR>', { desc = 'Close location list' })
vim.keymap.set('n', '[l', '<cmd>lprev<CR>', { desc = 'Previous location item' })
vim.keymap.set('n', ']l', '<cmd>lnext<CR>', { desc = 'Next location item' })

-- Window management
vim.keymap.set('n', '<leader>w<Left>', '<cmd>aboveleft vsplit<CR>', { desc = 'Split left' })
vim.keymap.set('n', '<leader>w<Down>', '<cmd>belowright split<CR>', { desc = 'Split down' })
vim.keymap.set('n', '<leader>w<Up>', '<cmd>aboveleft split<CR>', { desc = 'Split up' })
vim.keymap.set('n', '<leader>w<Right>', '<cmd>belowright vsplit<CR>', { desc = 'Split right' })
vim.keymap.set('n', '<leader>wq', '<cmd>close<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>wo', '<cmd>only<CR>', { desc = 'Close other windows' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equalize window sizes' })

-- ── Extended window management (<leader>w) ──
-- Navigate: Ctrl+hjkl (smart-splits, cross-layer)
-- Resize:   Ctrl+arrows (smart-splits)
-- Swap/zoom/rotate: <leader>w (prefix)

-- Swap buffer with adjacent split (focus follows the buffer)
vim.keymap.set('n', '<leader>wh', function()
  require('smart-splits').swap_buf_left()
  vim.cmd 'wincmd h'
end, { desc = 'Swap split left' })
vim.keymap.set('n', '<leader>wj', function()
  require('smart-splits').swap_buf_down()
  vim.cmd 'wincmd j'
end, { desc = 'Swap split down' })
vim.keymap.set('n', '<leader>wk', function()
  require('smart-splits').swap_buf_up()
  vim.cmd 'wincmd k'
end, { desc = 'Swap split up' })
vim.keymap.set('n', '<leader>wl', function()
  require('smart-splits').swap_buf_right()
  vim.cmd 'wincmd l'
end, { desc = 'Swap split right' })

-- Zoom toggle (save/restore window sizes, like tmux Alt+z)
vim.keymap.set('n', '<leader>wz', function()
  if vim.t.zoom_winrestcmd then
    vim.cmd(vim.t.zoom_winrestcmd)
    vim.t.zoom_winrestcmd = nil
  else
    vim.t.zoom_winrestcmd = vim.fn.winrestcmd()
    vim.cmd 'wincmd |'
    vim.cmd 'wincmd _'
  end
end, { desc = 'Zoom toggle' })

-- Toggle split orientation (vertical <-> horizontal)
vim.keymap.set('n', '<leader>wr', function()
  if vim.fn.winnr('$') == 1 then return end
  local win1_row = vim.fn.win_screenpos(1)[1]
  local win2_row = vim.fn.win_screenpos(2)[1]
  if win1_row == win2_row then
    vim.cmd 'wincmd K'
  else
    vim.cmd 'wincmd H'
  end
end, { desc = 'Toggle split orientation' })

-- ── Buffer management (<leader>b + [b/]b) ──
-- Cycle buffers (bracket convention, matches [d/]d, [q/]q)
vim.keymap.set('n', '[b', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })

-- Reorder buffers in the bufferline
vim.keymap.set('n', '<leader>bh', '<cmd>BufferLineMovePrev<CR>', { desc = 'Move buffer left' })
vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineMoveNext<CR>', { desc = 'Move buffer right' })

-- Jump to buffer by ordinal position (top-level for speed)
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    require('bufferline').go_to(i, true)
  end, { desc = 'Go to buffer ' .. i })
end
