;;; config.el -*- lexical-binding: t; -*-
;;
;; User configuration. Loaded after all Doom modules. Managed by kernix --
;; edits belong in ~/kernix/home/apps/emacs/doom/, not in ~/.config/doom.

;; User identity (matches kernix.git)
(setq user-full-name "hinriksnaer"
      user-mail-address "")

;; Fonts -- JetBrains Mono ships via kernix (home/desktop/fonts.nix)
(setq doom-font (font-spec :family "JetBrains Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "JetBrains Mono" :size 14))

;; Theme -- ayu dark (ships with doom-themes, no extra package needed)
(setq doom-theme 'doom-ayu-dark)

;; Line settings -- relative numbers, like neovim
(setq display-line-numbers-type 'relative)

;; Indentation -- match neovim's global 4-space default
(setq-default tab-width 4
              standard-indent 4)

;; Maximised frame on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

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

;; ── Debugger (dape) ──

;; dape's default `debugpy' template runs plain `python', which cannot
;; import debugpy on nix. Override it to use the dape-python wrapper
;; (defined in home/apps/emacs/default.nix) that injects the nix site-packages
;; path. Everything else matches dape's builtin template.
(after! dape
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
