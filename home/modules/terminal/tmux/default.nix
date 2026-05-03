# Tmux configuration -- shared across all profiles.
#
# Navigation model:
#   Alt + number     → switch window       (mirrors Super + number in Hyprland)
#   Alt + h/l        → prev/next window    (horizontal, matches dotbar layout)
#   Alt + j/k        → prev/next session   (vertical, sessions stack)
#   Alt + Tab        → last session
#   Alt + Space       → prefix for infrequent commands
#   prefix + Space   → sessionizer (fzf project picker)
#   Ctrl + h/j/k/l   → vim-tmux-navigator (cross-layer, unchanged)
{pkgs, ...}: {
  imports = [
    ./cli.nix
  ];

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

      # Pane base index
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # ── Alt layer (direct, no prefix) ──

      # Window switching: Alt + number
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Window cycling: Alt + h/l (horizontal)
      bind -n M-h previous-window
      bind -n M-l next-window

      # Session cycling: Alt + j/k (vertical)
      bind -n M-j switch-client -p
      bind -n M-k switch-client -n

      # Last session: Alt + Tab
      bind -n M-Tab switch-client -l

      # ── Prefix commands (Alt + Space, then key) ──

      # Sessionizer: prefix + Space
      bind Space display-popup -E "kernix-sessionizer"

      # Window management
      bind c new-window -c "#{pane_current_path}"
      bind q kill-window

      # Splits in current path (available if needed)
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # vi-mode copy
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}
