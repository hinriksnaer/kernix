;;; init.el --- Doom Emacs entry point -*- lexical-binding: t; -*-
;;
;; Doom module manifest. This file controls which Doom modules are enabled
;; and in what order they load. Managed by kernix -- edits belong in
;; ~/kernix/home/apps/emacs/doom/, not in ~/.config/doom.

(doom! :input
       builtin

       :completion
       (corfu +orderless)  ; complete-as-you-type
       vertico             ; the bottom-up search engine

       :ui
       doom                ; the flagship theme
       dashboard           ; the splash screen
       hl-todo             ; highlight TODO/FIXME/NOTE/DEPRECATED
       modeline            ; a snazzy mode line
       ophints             ; highlight the region being edited
       (popup +defaults)   ; tame sudden windows
       vc-gutter           ; git diff markers in the fringe
       workspaces          ; tab emulation, persistence

       :editor
       (evil +everywhere)  ; vim keybindings everywhere
       file-templates      ; scaffold new files by type
       fold                ; code folding
       format              ; automated prettification
       multiple-cursors    ; edit in many places at once
       snippets            ; my elves. They type so I don't have to
       undo-tree           ; better, persistent undo

       :emacs
       (dired +dirvish)   ; the file manager that owns your heart
       electric           ; smarter syntax highlighting
       ibuffer            ; interactive buffer management
       undo               ; persistent undo across sessions
       vc                 ; version control integration

       :term
       vterm              ; a true terminal emulator in Emacs

       :checkers
       (syntax +flymake)  ; code linting
       spell              ; tasing you for misspelling mispelling
       grammar            ; tasing grammar for every language

       :tools
       (eval +overlay)    ; run code, show results inline
       lookup             ; navigate references and documentation
       lsp                ; language server protocol
       magit              ; git porcelain inside Emacs (replaces lazygit)
       editorconfig       ; per-project style config
       debugger           ; DAP integration (replaces nvim-dap)

       :os
       (:if IS-MAC macos) ; improve compatibility with macOS
       tty                ; improve the terminal Emacs experience

       :lang
       (cc +lsp)          ; C/C++/Obj-C
       emacs-lisp         ; the language of the gods
       (json +lsp)        ; At least it's not YAML
       markdown           ; writing docs for people too lazy to read code
       nix                ; this flake's own language
       (python +lsp)      ; beautiful is better than ugly
       (rust +lsp)        ; fearlessness guaranteed
       (sh +lsp)          ; she sells seashells by the sea shore
       yaml               ; JSON, but for humans

       :config
       (default +bindings +smartparens))
