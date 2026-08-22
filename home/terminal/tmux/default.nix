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
# │  Alt + hjkl            navigate panes (smart-splits, vim-aware)    │
# │  Alt + Ctrl + hjkl     swap panes (vim-aware)                      │
# │  Alt + Shift + hjkl    resize panes (smart-splits, vim-aware)      │
# │  Alt + arrows          create split in direction                   │
# │  Alt + z               zoom pane (fullscreen)                      │
# │  Alt + r               rotate layout (cycle)                      │
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
# │  Alt + n               rename session (name)                       │
# │  Alt + Shift + n       new session in current path                 │
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
}: let
  smartSplits = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "smart-splits";
    rtpFilePath = "smart-splits.tmux";
    version = "2.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "v2.1.0";
      hash = "sha256-IuJNQT0bN68K5lnw0ixyU/heG8V1+zUwlvm0mNvvHOw=";
    };
  };
in {
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
      {
        plugin = smartSplits;
        # Settings must be set BEFORE the plugin runs
        extraConfig = ''
          set -g @smart-splits_move_left_key  'M-h'
          set -g @smart-splits_move_down_key  'M-j'
          set -g @smart-splits_move_up_key    'M-k'
          set -g @smart-splits_move_right_key 'M-l'
          set -g @smart-splits_resize_left_key  'M-H'
          set -g @smart-splits_resize_down_key  'M-J'
          set -g @smart-splits_resize_up_key    'M-K'
          set -g @smart-splits_resize_right_key 'M-L'
          set -g @smart-splits_resize_step_size '3'
        '';
      }
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

    extraConfig = builtins.readFile ./keybinds.conf;
  };
}
