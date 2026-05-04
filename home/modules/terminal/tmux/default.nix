# Tmux configuration -- shared across all profiles.
#
# Unified navigation grammar (consistent with Hyprland + neovim):
#
#   Direction keys define the LEVEL:
#     hjkl  = View   (panes, windows, splits)
#     [/]   = Task   (windows, workspaces, buffers)
#
#   Modifiers define the ACTION (consistent across both levels):
#     bare  = Navigate
#     Ctrl  = Swap       (same-level exchange)
#     Shift = Resize     (view) / Move view to task (task)
#
#   Additional:
#     arrows = Create    (spawn split in direction)
#     1-9    = Task      (indexed jump)
#
# Where Mod = Super (Hyprland) or Alt (tmux).
#
# ┌─ View (hjkl) ──────────────────────────────────────────────────────┐
# │  Alt + hjkl            navigate panes                              │
# │  Alt + Ctrl + hjkl     swap panes                                  │
# │  Alt + Shift + hjkl    resize panes                                │
# │  Alt + arrows          create split in direction                   │
# │  Alt + z               zoom pane (fullscreen)                      │
# │  Alt + r               rotate layout (cycle)                      │
# │  Ctrl + hjkl           vim-tmux-navigator (cross-layer with nvim)  │
# └────────────────────────────────────────────────────────────────────┘
# ┌─ Task ([/] + 1-9) ────────────────────────────────────────────────┐
# │  Alt + [ / ]           prev/next window                            │
# │  Alt + 1-9             switch to window N                          │
# │  Alt + Ctrl + [ / ]    swap window positions                       │
# │  Alt + Shift + [ / ]   move pane to prev/next window              │
# │  Alt + Shift + 1-9     move pane to window N                       │
# │  Alt + Ctrl + Enter    break pane to new window                   │
# │  Alt + Enter           new window                                  │
# │  Alt + q               kill pane (view)                            │
# └────────────────────────────────────────────────────────────────────┘
# ┌─ Context (session) ───────────────────────────────────────────────┐
# │  Alt + f               fzf session finder                          │
# │  Alt + Tab             previous session                            │
# └────────────────────────────────────────────────────────────────────┘
# ┌─ Prefix (Alt+Space) ──────────────────────────────────────────────┐
# │  Space                 sessionizer (fzf project picker)            │
# │  ,                     rename window          (tmux default)       │
# │  $                     rename session          (tmux default)      │
# │  d                     detach                  (tmux default)      │
# │  [                     copy mode               (tmux default)      │
# │  v / C-v / y           begin / rectangle / yank (copy-mode-vi)    │
# └────────────────────────────────────────────────────────────────────┘
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
    TMUX_CONF="${config.home.homeDirectory}/.config/tmux/tmux.conf"
    if [ -f "$TMUX_CONF" ] && command -v tmux >/dev/null 2>&1; then
      tmux list-sessions >/dev/null 2>&1 && tmux source-file "$TMUX_CONF" >/dev/null 2>&1 || true
    fi
  '';

  programs.tmux = {
    enable = true;
    prefix = "M-Space";
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    # 25ms: allows tmux to combine ESC + key from home row mods
    # (0ms is too aggressive -- HRM firmware needs ~10-25ms for multi-mod combos)
    escapeTime = 25;
    historyLimit = 50000;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
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

      # Pane borders
      set -g pane-border-lines heavy
      set -g pane-border-style "fg=colour8"
      set -g pane-active-border-style "fg=colour14"

      # Pane/window base index
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # ── View level: pane (hjkl) ──

      # Navigate panes: Alt + hjkl
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Swap panes: Alt + Ctrl + hjkl (focus follows swapped content)
      bind -n M-C-h swap-pane -t '{left-of}' \; select-pane -L
      bind -n M-C-j swap-pane -t '{down-of}' \; select-pane -D
      bind -n M-C-k swap-pane -t '{up-of}' \; select-pane -U
      bind -n M-C-l swap-pane -t '{right-of}' \; select-pane -R

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

      # Rotate layout: Alt + r
      bind -n M-r next-layout

      # ── Task level: window ([/] + 1-9) ──

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

      # Move pane to adjacent window: Alt + Shift + [ / ] (side-by-side join)
      bind -n M-'{' join-pane -h -t :-1
      bind -n M-'}' join-pane -h -t :+1

      # Move pane to window N: Alt + Shift + 1-9 (Shift+num = !@#$%^&*()
      bind -n M-'!' join-pane -h -t :1
      bind -n M-'@' join-pane -h -t :2
      bind -n M-'#' join-pane -h -t :3
      bind -n M-'$' join-pane -h -t :4
      bind -n M-'%' join-pane -h -t :5
      bind -n M-'^' join-pane -h -t :6
      bind -n M-'&' join-pane -h -t :7
      bind -n M-'*' join-pane -h -t :8
      bind -n M-'(' join-pane -h -t :9

      # Break pane to new window: Alt + Ctrl + Enter
      bind -n M-C-Enter break-pane

      # New window: Alt + Enter
      bind -n M-Enter new-window -c "#{pane_current_path}"

      # Kill pane: Alt + q (kills window if last pane)
      bind -n M-q kill-pane

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
