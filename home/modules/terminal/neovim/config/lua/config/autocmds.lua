-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Disable folding for markdown files
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Disable folding for markdown',
  group = vim.api.nvim_create_augroup('markdown-no-fold', { clear = true }),
  pattern = { 'markdown' },
  callback = function()
    vim.wo.foldmethod = 'manual'
    vim.wo.foldenable = false
  end,
})

