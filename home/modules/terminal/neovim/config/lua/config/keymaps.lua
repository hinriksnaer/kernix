-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
-- See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- LSP keymaps
vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, { desc = 'Diagnostic location list' })
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

-- Better text movement
-- Move lines up/down in visual mode (Alt+h/l used by smart-splits for window resize)
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Better indenting - stay in visual mode
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

-- Better paste - don't yank replaced text
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste without yanking' })

-- Window resizing is handled by smart-splits.nvim plugin
-- Use Alt+hjkl for resizing (arrow keys kept free for other uses)

-- Better search - center screen on next/previous match
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result (centered)' })

-- Center screen on common jumps
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })

-- Buffer navigation
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = 'Next buffer' })

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
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<leader>ws', '<cmd>split<CR>', { desc = 'Horizontal split' })
vim.keymap.set('n', '<leader>wc', '<cmd>close<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>wo', '<cmd>only<CR>', { desc = 'Close other windows' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equalize window sizes' })
