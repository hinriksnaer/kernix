return {
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- Mason must be loaded before its dependents so we need to set it up here.
    -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },

    -- Allows extra capabilities provided by blink.cmp
    'saghen/blink.cmp',
  },
  config = function()
    -- Runs when an LSP attaches to a buffer; sets up keymaps and highlights.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kernix-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        -- Navigation (routed through fzf-lua for fuzzy multi-result handling).
        local fzf = require 'fzf-lua'
        -- Auto-jumping on a single result (`jump1`) is on by default;
        -- `unique_line_items` collapses results pointing at the same file+line
        -- so duplicate locations from a single server still auto-jump.
        local jump_opts = { unique_line_items = true }
        map('gd', function() fzf.lsp_definitions(jump_opts) end, 'Go to Definition')
        map('gD', function() fzf.lsp_declarations(jump_opts) end, 'Go to Declaration')
        map('gr', function() fzf.lsp_references(jump_opts) end, 'Go to References')
        map('gi', function() fzf.lsp_implementations(jump_opts) end, 'Go to Implementation')
        map('<leader>cD', function() fzf.lsp_typedefs(jump_opts) end, 'Type Definition')
        map('<leader>cs', fzf.lsp_live_workspace_symbols, 'Workspace Symbols')

        -- Hover & Info
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>lk', vim.lsp.buf.signature_help, 'Signature Documentation')

        -- Actions
        map('<leader>cn', vim.lsp.buf.rename, 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')

        -- Diagnostics
        map('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic')
        map(']d', vim.diagnostic.goto_next, 'Go to next diagnostic')
        map('<leader>le', vim.diagnostic.open_float, 'Show diagnostic')
        map('<leader>lq', function() require('fzf-lua').diagnostics_document() end, 'Document Diagnostics')

        -- Formatting
        map('<leader>cf', function()
          vim.lsp.buf.format { async = true }
        end, 'Format')
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer some lsp support methods only in specific files
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        -- Highlight references of the word under cursor (CursorHold).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kernix-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kernix-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kernix-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- Toggle inlay hints
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>lh', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, 'Toggle inlay hints')
        end
      end,
    })

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
      },
    }

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Servers on $PATH (Nix/venv) -- set up directly, not via Mason.
    vim.lsp.config('pyrefly', { capabilities = capabilities })
    vim.lsp.enable('pyrefly')

    -- lua_ls binary comes from Mason (see ensure_installed below); mason.nvim
    -- prepends mason/bin to PATH, so the default cmd resolves.
    vim.lsp.config('lua_ls', {
      capabilities = capabilities,
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    })
    vim.lsp.enable('lua_ls')

    -- Tools for Mason to install (LSPs on $PATH are set up directly above).
    local ensure_installed = {
      'lua-language-server', -- Lua LSP
      'stylua',   -- Lua formatter
      'codelldb', -- C/C++ debugger
    }
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- Mason is only used to install tools -- never to enable servers.
    -- `automatic_enable` (on by default) attaches EVERY package in mason's
    -- data dir as an LSP, e.g. a stale pyright alongside pyrefly, which made
    -- `gd` open the fzf picker with each result duplicated.
    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_installation = false,
      automatic_enable = false,
    }
  end,
}
