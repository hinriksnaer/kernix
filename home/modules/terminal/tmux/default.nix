# Tmux configuration -- shared across all profiles.
#
# Unified navigation model (consistent with Hyprland):
#
#   Navigate:   Mod + hjkl           (focus)
#   Swap:       Mod + Ctrl + hjkl    (exchange positions)
#   Resize:     Mod + Shift + hjkl   (scale)
#   Create:     Mod + arrows         (spawn in direction)
#   Task:       Mod + [Ctrl +] 1-9   (indexed jump / move view to)
#
# Where Mod = Super (Hyprland) or Alt (tmux).
#
# ┌─ View level (pane -- directional) ──────────────────────────────────┐
# │  Alt + hjkl            navigate panes                               │
# │  Alt + Ctrl + hjkl     swap panes                                   │
# │  Alt + Shift + hjkl    resize panes                                 │
# │  Alt + arrows          create split in direction                    │
# │  Alt + z               zoom pane (fullscreen)                       │
# │  Ctrl + hjkl           vim-tmux-navigator (cross-layer with nvim)  │
# └─────────────────────────────────────────────────────────────────────┘
# ┌─ Task level (window -- indexed + directional) ──────────────────────┐
# │  Alt + 1-9             switch to window N                           │
# │  Alt + [ / ]           prev/next window                             │
# │  prefix + 1-9          move pane to window N                       │
# │  Alt + Ctrl + [ / ]    swap window position (reorder)              │
# │  Alt + Shift + [ / ]   move pane to prev/next window              │
# │  Alt + Ctrl + Enter    break pane to new window                    │
# │  Alt + Enter           new window                                   │
# │  Alt + q               kill window                                  │
# └─────────────────────────────────────────────────────────────────────┘
# ┌─ Context (session -- special) ──────────────────────────────────────┐
# │  Alt + f               fzf session finder                           │
# │  Alt + Tab             previous session                             │
# └─────────────────────────────────────────────────────────────────────┘
# ┌─ Prefix (Alt+Space, then key) ──────────────────────────────────────┐
# │  1-9                   move pane to window N (join-pane)           │
# │  Space                 sessionizer (fzf project picker)             │
# │  ,                     rename window (tmux default)                 │
# │  $                     rename session (tmux default)                │
# │  d                     detach (tmux default)                        │
# │  [                     copy mode (tmux default)                     │
# │  v / C-v / y           begin / rectangle / yank (copy-mode-vi)     │
# └─────────────────────────────────────────────────────────────────────┘
{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./cli.nix
  ];

  # Reload tmux config after Home Manager switch (if server is running)
  home.activation.reloadTmux = config.lib.dag.entryAfter ["linkGeneration"] ''
    if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
      tmux source-file "${config.home.homeDirectory}/.config/tmux/tmux.conf" 2>/dev/null || true
    fi
  '';

  programs.tmux = {
    enable = true;
    prefix = "M-Space";
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      {
        plugin = dotbar;
        # Dotbar settings must be set BEFORE the plugin runs
        extraConfig = ''
          set -g @tmux-dotbar-position top
          set -g @tmux-dotbar-fg "colour8"
          set -g @tmux-dotbar-bg "default"
          set -g @tmux-dotbar-fg-current "colour7"
          set -g @tmux-dotbar-fg-session "colour8"
          set -g @tmux-dotbar-fg-prefix "colour14"
        '';
      }
    ];

    extraConfig = ''
      set -g set-clipboard on
      set -g focus-events on
      set-option -sa terminal-overrides ",xterm*:Tc,tmux*:Tc"

      # Extended keys for modified arrow key sequences from modern terminals
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      # Pane/window base index
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # ── View level: pane (directional) ──

      # Navigate panes: Alt + hjkl
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Swap panes: Alt + Ctrl + hjkl
      bind -n M-C-h swap-pane -t '{left-of}'
      bind -n M-C-j swap-pane -t '{down-of}'
      bind -n M-C-k swap-pane -t '{up-of}'
      bind -n M-C-l swap-pane -t '{right-of}'

      # Resize panes: Alt + Shift + hjkl
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 5
      bind -n M-K resize-pane -U 5
      bind -n M-L resize-pane -R 5

      # Create split in direction: Alt + arrows
      bind -n M-Left split-window -hb -c "#{pane_current_path}"
      bind -n M-Down split-window -v -c "#{pane_current_path}"
      bind -n M-Up split-window -vb -c "#{pane_current_path}"
      bind -n M-Right split-window -h -c "#{pane_current_path}"

      # Zoom pane: Alt + z
      bind -n M-z resize-pane -Z

      # ── Task level: window (indexed) ──

      # Navigate windows: Alt + 1-9
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Cycle windows: Alt + [ / ]
      bind -n M-[ previous-window
      bind -n M-] next-window

      # Swap window position: Alt + Ctrl + [ / ] (Ctrl = swap)
      bind -n M-C-[ swap-window -t -1\; select-window -t -1
      bind -n M-C-] swap-window -t +1\; select-window -t +1

      # Move pane to adjacent window: Alt + Shift + [ / ]
      bind -n M-S-'[' join-pane -t :-1
      bind -n M-S-']' join-pane -t :+1

      # Move pane to window N: prefix + 1-9
      # (Ctrl+number can't be encoded by terminals, so this goes behind prefix)
      bind 1 join-pane -t :1
      bind 2 join-pane -t :2
      bind 3 join-pane -t :3
      bind 4 join-pane -t :4
      bind 5 join-pane -t :5
      bind 6 join-pane -t :6
      bind 7 join-pane -t :7
      bind 8 join-pane -t :8
      bind 9 join-pane -t :9

      # Break pane to new window: Alt + Ctrl + Enter
      bind -n M-C-Enter break-pane

      # New window: Alt + Enter
      bind -n M-Enter new-window -c "#{pane_current_path}"

      # Kill window: Alt + q
      bind -n M-q kill-window

      # ── Context: session (special) ──

      # Session finder: Alt + f
      bind -n M-f display-popup -E "tmux list-sessions -F '#{session_name}' | fzf --reverse --border --prompt='session: ' | xargs -r tmux switch-client -t"

      # Last session: Alt + Tab
      bind -n M-Tab switch-client -l

      # ── Prefix commands (Alt + Space, then key) ──

      # Sessionizer: prefix + Space
      bind Space display-popup -E "kernix-sessionizer"

      # vi-mode copy
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}
