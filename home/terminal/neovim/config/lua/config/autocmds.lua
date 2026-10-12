-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kernix-highlight-yank', { clear = true }),
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

-- dap-ui float borders follow the theme's Title color (each theme's
-- heading/accent color; ayu-dark: the palette orange #ff8f40). Needed because
-- neovim-ayu paints DapUIFloatBorder with panel_border (black on this bg) and
-- other themes define it equally dull. Copies only the color, not attributes,
-- so bold Title styles don't fatten the border glyphs. Re-applies on every
-- colorscheme switch (kernix-theme runtime switching included).
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'dap-ui float borders follow the theme Title color',
  group = vim.api.nvim_create_augroup('kernix-dapui-border', { clear = true }),
  callback = function()
    local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID 'Title'), 'fg#')
    if fg:match '^#%x+$' then
      vim.api.nvim_set_hl(0, 'DapUIFloatBorder', { fg = fg })
    end
  end,
})

