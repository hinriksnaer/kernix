return {
  'mikavilpas/yazi.nvim',
  dependencies = { 'folke/which-key.nvim' },
  event = 'VeryLazy',
  keys = {
    {
      '<leader>y',
      '<cmd>Yazi<cr>',
      desc = 'Yazi (current file)',
    },
    {
      '<leader>Y',
      '<cmd>Yazi cwd<cr>',
      desc = 'Yazi (cwd)',
    },
  },
  opts = {
    open_for_directories = false, -- oil.nvim handles directories
  },
}
