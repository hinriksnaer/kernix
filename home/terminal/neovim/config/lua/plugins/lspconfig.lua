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
        -- Navigation (routed through fzf-lua for fuzzy multi-result handling)
        local fzf = require 'fzf-lua'
        local jump1 = { jump_to_single_result = true }
        map('gd', function() fzf.lsp_definitions(jump1) end, 'Go to Definition')
        map('gD', function() fzf.lsp_declarations(jump1) end, 'Go to Declaration')
        map('gr', function() fzf.lsp_references(jump1) end, 'Go to References')
        map('gi', function() fzf.lsp_implementations(jump1) end, 'Go to Implementation')
        map('<leader>cD', function() fzf.lsp_typedefs(jump1) end, 'Type Definition')
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

    -- Servers managed by Mason
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }

    -- Tools for Mason to install (LSPs on $PATH are set up directly above).
    local ensure_installed = {
      'stylua',   -- Lua formatter
      'codelldb', -- C/C++ debugger
    }
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_installation = false,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
