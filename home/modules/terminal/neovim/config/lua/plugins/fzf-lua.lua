-- fzf-lua - Fast, feature-rich fuzzy finder
-- Uses native fzf for blazing speed with great defaults

return {
  'ibhagwan/fzf-lua',
  lazy = false, -- Load immediately
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local actions = require 'fzf-lua.actions'

    require('fzf-lua').setup {
      -- Use fzf-native for best performance
      'default-title',

      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = 'rounded',
        preview = {
          default = 'bat',
          border = 'border',
          wrap = 'nowrap',
          hidden = 'nohidden', -- Start with preview visible
          vertical = 'down:45%',
          horizontal = 'right:50%',
          layout = 'flex',
          flip_columns = 120,
          scrollbar = 'float',
        },
      },

      keymap = {
        builtin = {
          ['<C-d>'] = 'preview-page-down',
          ['<C-u>'] = 'preview-page-up',
        },
        fzf = {
          ['ctrl-q'] = 'select-all+accept',
          ['ctrl-d'] = 'preview-page-down',
          ['ctrl-u'] = 'preview-page-up',
        },
      },

      files = {
        prompt = 'Files❯ ',
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
        rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
      },

      grep = {
        prompt = 'Rg❯ ',
        input_prompt = 'Grep For❯ ',
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e]],
      },

      buffers = {
        prompt = 'Buffers❯ ',
        file_icons = true,
        color_icons = true,
        sort_lastused = true,
        actions = {
          ['ctrl-x'] = { fn = actions.buf_del, reload = true },
        },
      },

      oldfiles = {
        prompt = 'History❯ ',
        cwd_only = true,
        stat_file = true,
        include_current_session = true,
      },

      helptags = {
        prompt = 'Help❯ ',
        actions = {
          ['default'] = actions.help,
        },
      },

      lsp = {
        prompt_postfix = '❯ ',
        cwd_only = false,
        async_or_timeout = 5000,
        file_icons = true,
        git_icons = false,
        lsp_icons = true,
        severity = 'hint',
      },
    }

    -- Register as vim.ui.select provider (used by DAP, LSP code actions, etc.)
    require('fzf-lua').register_ui_select()

    -- Set up keybindings
    --
    -- Shared concepts use the SAME lowercase letter in both groups:
    --   g = grep    (fg / sg)     s = symbols     (fs / ss)
    --   d = diag    (fd / sd)     h = hunks       (fh / sh)
    --   c = commits (fc / sc)
    --
    -- Non-shared items use unique or uppercase keys.

    local wk = require 'which-key'
    wk.add {
      ----------------------------------------------------------------
      -- Find (project) — <leader>f
      ----------------------------------------------------------------

      -- Files and buffers
      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Files' },
      { '<C-p>', '<cmd>FzfLua files<cr>', desc = 'Find Files', mode = 'n' },
      {
        '<leader>fF',
        function()
          require('fzf-lua').files { cwd = vim.fn.expand '%:p:h' }
        end,
        desc = 'Files (relative to current)',
      },
      { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Buffers' },
      { '<leader>fo', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent Files' },

      -- Shared: grep, symbols, diagnostics (lowercase — mirrors <leader>s)
      { '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Grep' },
      { '<leader>fs', '<cmd>FzfLua lsp_live_workspace_symbols<cr>', desc = 'Symbols' },
      { '<leader>fd', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Diagnostics' },

      -- Shared: git hunks, commits (lowercase — mirrors <leader>s)
      { '<leader>fh', '<cmd>FzfLua git_hunks<cr>', desc = 'Hunks' },
      { '<leader>fc', '<cmd>FzfLua git_commits<cr>', desc = 'Commits' },

      -- Project-only (uppercase / unique keys)
      { '<leader>fw', '<cmd>FzfLua grep_cword<cr>', desc = 'Grep Word Under Cursor' },
      { '<leader>fw', '<cmd>FzfLua grep_visual<cr>', desc = 'Grep Visual Selection', mode = 'v' },
      { '<leader>fG', '<cmd>FzfLua git_status<cr>', desc = 'Git Status' },
      { '<leader>fH', '<cmd>FzfLua help_tags<cr>', desc = 'Help' },
      { '<leader>fC', '<cmd>FzfLua colorschemes<cr>', desc = 'Colorschemes' },
      { '<leader>fk', '<cmd>FzfLua keymaps<cr>', desc = 'Keymaps' },
      { '<leader>fm', '<cmd>FzfLua marks<cr>', desc = 'Marks' },
      { '<leader>fr', '<cmd>FzfLua resume<cr>', desc = 'Resume' },

      ----------------------------------------------------------------
      -- Search (file) — <leader>s
      ----------------------------------------------------------------

      -- Shared: grep, symbols, diagnostics (lowercase — mirrors <leader>f)
      { '<leader>sg', '<cmd>FzfLua lgrep_curbuf<cr>', desc = 'Grep' },
      { '<leader>ss', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'Symbols' },
      { '<leader>sd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Diagnostics' },

      -- Shared: git hunks, commits (lowercase — mirrors <leader>f)
      {
        '<leader>sh',
        function()
          require('fzf-lua').git_hunks { file = vim.fn.expand '%' }
        end,
        desc = 'Hunks',
      },
      { '<leader>sc', '<cmd>FzfLua git_bcommits<cr>', desc = 'Commits' },

      -- File-only
      { '<leader>sl', '<cmd>FzfLua blines<cr>', desc = 'Lines' },
      { '<leader>st', '<cmd>FzfLua treesitter<cr>', desc = 'Treesitter' },
      { '<leader>sb', '<cmd>FzfLua git_blame<cr>', desc = 'Blame' },

      -- Quick alias
      { '<leader>/', '<cmd>FzfLua blines<cr>', desc = 'Search Lines (buffer)' },
    }
  end,
}
