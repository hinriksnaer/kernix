;;; config.el -*- lexical-binding: t; -*-
;;
;; User configuration. Loaded after all Doom modules. Managed by kernix --
;; edits belong in ~/kernix/home/apps/emacs/doom/, not in ~/.config/doom.

;; User identity (matches kernix.git)
(setq user-full-name "hinriksnaer"
      user-mail-address "")

;; Fonts -- Maple Mono NF matches kernix.font.monospace (home/desktop/
;; fonts.nix). The NF variant embeds nerd font glyphs, so modeline/
;; dashboard icons render correctly. Keep in sync if kernix.font changes.
(setq doom-font (font-spec :family "Maple Mono NF" :size 14)
      doom-variable-pitch-font (font-spec :family "Maple Mono NF" :size 14))

;; Theme -- ayu dark (ships with doom-themes, no extra package needed)
(setq doom-theme 'doom-ayu-dark)

;; Line settings -- relative numbers, like neovim
(setq display-line-numbers-type 'relative)

;; Indentation -- match neovim's global 4-space default
(setq-default tab-width 4
              standard-indent 4)

;; Maximised frame on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; Window navigation is stock evil C-w grammar (C-w h/j/k/l) -- no tmux
;; handoff needed; see the no-tmux assumption note in default.nix comments.

;; ── Neovim parity: search & motion ──

;; Center the screen on search results (nzzzv / Nzzzv in keymaps.lua)
(defadvice! evil-ex-search-next--recenter (&rest _)
  :after #'evil-ex-search-next
  (evil-scroll-line-to-center nil))
(defadvice! evil-ex-search-previous--recenter (&rest _)
  :after #'evil-ex-search-previous
  (evil-scroll-line-to-center nil))

;; Centered half-page jumps (C-d zz / C-u zz)
(defadvice! evil-scroll-down--recenter (&rest _)
  :after #'evil-scroll-down
  (evil-scroll-line-to-center nil))
(defadvice! evil-scroll-up--recenter (&rest _)
  :after #'evil-scroll-up
  (evil-scroll-line-to-center nil))

;; ── Neovim parity: visual-mode editing ──

;; Keep the visual selection active when indenting (<gv / >gv)
(evil-define-operator evil-indent-right-visual (beg end)
  "Indent right and keep the selection."
  (evil-shift-right beg end)
  (activate-mark))
(evil-define-operator evil-indent-left-visual (beg end)
  "Indent left and keep the selection."
  (evil-shift-left beg end)
  (activate-mark))
(define-key evil-visual-state-map (kbd ">") #'evil-indent-right-visual)
(define-key evil-visual-state-map (kbd "<") #'evil-indent-left-visual)

;; Paste without clobbering the register ("_dP in keymaps.lua)
(define-key evil-visual-state-map (kbd "P")
  #'evil-paste-from-register)

;; <Esc> clears search highlighting, like nvim's nohlsearch
(define-key evil-normal-state-map (kbd "<escape>")
  #'evil-ex-nohighlight)

;; ── Neovim parity: file browsing (oil.nvim style) ──

;; `-` opens dired at the current file's directory (oil.nvim muscle memory)
(map! :nv "-" #'dired-jump)
;; Inside dired, `-` goes up a directory, like oil's repeated `-`
(map! :after dired
      :map dired-mode-map
      :n "-" #'dired-up-directory)

;; ── LSP ──

;; Don't ask "are you sure" when quitting (SPC q q / C-x C-c)
(setq confirm-kill-emacs nil)

;; Terminal mouse -- Doom's :os tty module only enables xterm-mouse-mode on
;; Emacs < 31 (31 is supposed to auto-detect), which doesn't trigger under
;; ghostty's TERM. Enable it explicitly on tty frames.
(add-hook 'tty-setup-hook #'xterm-mouse-mode)

;; ── Debugger (dape) ──

;; dape only ships autoload cookies for 3 of its ~30 commands, so Doom's
;; `SPC d' bindings raise "Wrong type argument: commandp" until dape is
;; loaded. Declare the rest ourselves (interactive = t so `commandp' is
;; satisfied and the keypress triggers the actual load).
(dolist (cmd '(dape-pause dape-continue dape-next dape-step-in dape-step-out
                  dape-restart dape-repl dape-memory dape-disassemble
                  dape-until
                  dape-breakpoint-log dape-breakpoint-expression
                  dape-breakpoint-hits dape-breakpoint-toggle
                  dape-breakpoint-remove-all dape-select-thread
                  dape-select-stack dape-stack-select-down
                  dape-stack-select-up dape-evaluate-expression
                  dape-watch-dwim dape-disconnect-quit dape-quit))
  (autoload cmd "dape" nil t))

;; `dape-until' (run to cursor) is missing from Doom's `SPC d' map
(map! :leader :n "d u" #'dape-until)

;; dape's default `debugpy' template runs plain `python', which cannot
;; import debugpy on nix. Override it to use the dape-python wrapper
;; (defined in home/apps/emacs/default.nix) that injects the nix site-packages
;; path. Everything else matches dape's builtin template.
(after! dape
  ;; ── Debugger aesthetics (presentation only) ──

  ;; Terminal breakpoints: circle instead of "B" (GUI keeps its fringe
  ;; bitmap regardless)
  (setq dape-breakpoint-margin-string "●")

  ;; Align the name/value columns in scope/watch buffers -- the ragged
  ;; default is the single biggest "feels rough" detail
  (setq dape-info-variable-table-aligned t)

  ;; Declutter the stack buffer: frame addresses are noise when debugging
  ;; plain Python
  (setq dape-info-stack-buffer-addresses nil
        dape-info-thread-buffer-addresses nil)

  ;; Stopped line: full-width hl-line style highlight instead of the
  ;; near-invisible default face; breakpoints in red
  (custom-set-faces!
    '(dape-source-line-face :inherit hl-line :extend t)
    '(dape-breakpoint-face :inherit error))

  ;; ── Complex types (torch tensors, cutedsl IR) ──
  ;; DAP variable tables show debugpy's structural view: a tensor expands
  ;; to its fields (data, grad_fn, size, dtype, ...) with the value column
  ;; rendered by the object's __repr__. No debugger can do better than the
  ;; repr the debuggee provides -- the levers are column width, expansion
  ;; depth, and (debuggee-side) torch.set_printoptions / custom __repr__.
  (setq dape-info-variable-table-row-config '((name . 40) (value . 120) (type . 0))
        ;; auto-expand top-level structures in scope/watch buffers
        dape-variable-auto-expand-alist '((hover . 1) (repl . 1) (watch . 2))
        ;; inlay hints: show full variable names
        dape-inlay-hints-variable-name-max 60)

  ;; dape's default `debugpy' template runs plain `python', which cannot
  ;; import debugpy on nix. Override it to use the dape-python wrapper
  ;; (defined in home/apps/emacs/default.nix) that injects the nix
  ;; site-packages path. Everything else matches dape's builtin template.
  (setf (alist-get 'debugpy dape-configs)
        `( modes (python-mode python-ts-mode)
           command "dape-python"
           command-args ("-m" "debugpy.adapter" "--host" "0.0.0.0" "--port" :autoport)
           port :autoport
           :request "launch"
           :type "python"
           :cwd dape-cwd
           :program dape-buffer-default
           :args []
           :justMyCode nil
           :console "integratedTerminal"
           :showReturnValue t
           :stopOnEntry nil)))

;; Take `nix-direnv` environments into account for lsp/compile
(after! lsp-mode
  (setq lsp-resolve-globally nil))
