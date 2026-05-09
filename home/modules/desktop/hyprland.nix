# Hyprland window manager configuration.
# Theme colors loaded at runtime via source (swapped by kernix-theme-set).
# Monitor config comes from config.monitors (set per-host in profiles).
{
  config,
  lib,
  pkgs,
  settings,
  hostname,
  ...
}: let
  hostSettings = settings.hosts.${hostname};
  monitors = config.monitors;
  hasMultipleMonitors = builtins.length monitors > 1;
  primaryMonitor = lib.findFirst (m: m.primary) (builtins.head monitors) monitors;
  isHiDPI = builtins.any (m: m.scale > 1.0) monitors;
  isDesktop = hostname == "desktop";
in {
  # ── Wayland packages ──
  home.packages = with pkgs; [
    swaybg
    qt5.qtwayland
    qt6.qtwayland
    hyprland-qtutils
    wlr-randr
    wlogout
  ];

  # ── Wayland session variables ──
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    MOZ_ENABLE_WAYLAND = "1";
    CLUTTER_BACKEND = "wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # ── UWSM auto-start (TTY login only) ──
  programs.zsh.initContent = lib.mkOrder 100 ''
    if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]] && uwsm check may-start 2>/dev/null; then
        exec uwsm start hyprland-uwsm.desktop
    fi
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # NixOS system module installs Hyprland
    systemd.enable = false; # UWSM or NixOS manages the session

    settings = {
      # ── Environment ──
      env =
        [
          "KERNIX_PATH,$HOME/.local/share/kernix"
        ]
        ++ lib.optionals isDesktop [
          "SSH_AUTH_SOCK,$HOME/.ssh/proton-pass-agent.sock"
        ];

      # ── Monitors (from config.monitors, set in profiles) ──
      monitor =
        map (
          m: "${m.name}, ${m.resolution}, ${m.position}, ${toString m.scale}"
        )
        monitors;

      # ── Input ──
      input = {
        kb_layout = "us,is";
        kb_options = "compose:caps";
        follow_mouse = 1;
        mouse_refocus = false;
        sensitivity = 0;
      };

      # ── Appearance ──
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout =
          if isHiDPI
          then "master"
          else "dwindle";
        "col.active_border" = "rgba(ff6a1fee)";
        "col.inactive_border" = "rgba(595959aa)";
      };

      decoration = {
        rounding = 4;
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        fullscreen_opacity = 1.0;
        dim_inactive = true;
        dim_strength = 0.15;

        shadow = {
          enabled = true;
          range = 2;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 1;
          new_optimizations = true;
          xray = false;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
          "easeIn,0.42,0,1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 3, easeOutQuint"
          "windows, 1, 5, easeOutQuint"
          "windowsIn, 1, 4, easeOutQuint, popin 87%"
          "windowsOut, 1, 2, linear, popin 87%"
          "windowsMove, 1, 7, easeOutQuint"
          "fadeIn, 1, 2, almostLinear"
          "fadeOut, 1, 2, almostLinear"
          "fade, 1, 3, quick"
          "layers, 1, 3, easeOutQuint"
          "layersIn, 1, 2, easeOutQuint, fade"
          "layersOut, 1, 2, easeOutQuint, fade"
          "fadeLayersIn, 1, 2, almostLinear"
          "fadeLayersOut, 1, 2, almostLinear"
          "workspaces, 0, 1, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "slave";
        mfact = 0.5;
        orientation = "center";
        slave_count_for_center_master = 0;
        center_master_fallback = "right";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
        disable_autoreload = false;
        anr_missed_pings = 3;
        enable_swallow = true;
        swallow_regex = "^(${config.kernix.terminal.windowClass})$";
      };

      cursor =
        {
          no_hardware_cursors = true;
          hide_on_key_press = true;
        }
        // lib.optionalAttrs (primaryMonitor.name != "") {
          default_monitor = primaryMonitor.name;
        };

      xwayland.force_zero_scaling = true;

      # ── Window rules ──
      windowrule = [
        {
          name = "file-dialogs";
          "match:title" = "^(Open File|Save File|Open Folder)$";
          float = true;
        }
        {
          name = "floating-utils";
          "match:class" = "^(pavucontrol|nm-connection-editor|blueman-manager|mpv|polkit-gnome-authentication-agent-1)$";
          float = true;
        }
        {
          name = "pip";
          "match:title" = "^(Picture-in-Picture)$";
          float = true;
          pin = true;
        }
        {
          name = "terminal-opacity";
          "match:class" = "^(${config.kernix.terminal.windowClass})$";
          opacity = "0.95 0.85";
        }
        {
          name = "comms-workspace";
          "match:class" = "^(discord|Slack)$";
          workspace = 3;
        }
      ];

      # ── Autostart ──
      exec-once =
        [
          "dbus-update-activation-environment --systemd --all"
          "nm-applet"
          "waybar"
          "mako"
          "wl-paste --watch cliphist store"
          "swaybg -i $HOME/.config/hypr/wallpapers/current -m fill"
          "sleep 2 && kernix-theme-refresh 2>/dev/null || true"
        ]
        ++ lib.optionals isDesktop [
          # Proton Pass SSH agent (desktop only)
          "bash -c 'nohup pass-cli ssh-agent start > /tmp/proton-pass-agent.log 2>&1 &'"
        ];

      # ── Keybinds ──
      "$mainMod" = "SUPER";

      bind = [
        # Emergency
        "CTRL ALT, BackSpace, exit,"

        # Applications
        "$mainMod, Return, exec, ${config.kernix.terminal.command}"
        "$mainMod SHIFT, Return, togglespecialworkspace, emergency"
        "$mainMod, B, exec, firefox"
        "$mainMod, E, exec, ${config.kernix.terminal.command} ${config.kernix.terminal.execFlag} yazi"
        "$mainMod, Space, exec, rofi -show drun"
        "$mainMod, Escape, exec, hyprlock"

        # Window management
        "$mainMod, Q, killactive,"
        "$mainMod SHIFT, E, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"
        "$mainMod, P, pseudo,"
        "$mainMod ALT, R, togglesplit,"
        ''$mainMod ALT, Space, exec, hyprctl keyword general:layout "$([ "$(hyprctl getoption general:layout -j | grep -o '"dwindle\|"master' | tr -d '"')" = "dwindle" ] && echo master || echo dwindle)"''

        # Focus (vim)
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Swap windows: Super + Ctrl + hjkl (Ctrl = swap)
        "$mainMod CTRL, h, swapwindow, l"
        "$mainMod CTRL, l, swapwindow, r"
        "$mainMod CTRL, k, swapwindow, u"
        "$mainMod CTRL, j, swapwindow, d"

        # Resize windows: Super + Shift + hjkl (Shift = resize)
        "$mainMod SHIFT, h, resizeactive, -50 0"
        "$mainMod SHIFT, l, resizeactive, 50 0"
        "$mainMod SHIFT, k, resizeactive, 0 -50"
        "$mainMod SHIFT, j, resizeactive, 0 50"

        # Move windows: Super + arrows (arrows = structural move)
        "$mainMod, left, movewindow, l"
        "$mainMod, right, movewindow, r"
        "$mainMod, up, movewindow, u"
        "$mainMod, down, movewindow, d"

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod, Tab, workspace, previous"

        # Navigate workspaces: Super + [ / ]
        "$mainMod, bracketleft, workspace, e-1"
        "$mainMod, bracketright, workspace, e+1"

        # Swap workspaces: Super + Ctrl + [ / ] (Ctrl = swap, multi-monitor)
        # swapactiveworkspaces requires monitor names; uncomment for multi-monitor:
        # "$mainMod CTRL, bracketleft, swapactiveworkspaces, eDP-1 DP-1"
        # "$mainMod CTRL, bracketright, swapactiveworkspaces, eDP-1 DP-1"

        # Move view to adjacent task: Super + Shift + [ / ] (Shift = move view)
        "$mainMod SHIFT, bracketleft, movetoworkspace, e-1"
        "$mainMod SHIFT, bracketright, movetoworkspace, e+1"

        # Move view to task N: Super + Shift + 1-9 (Shift = move view)
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Mouse
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Keyboard layout
        "$mainMod CTRL, Space, exec, hyprctl switchxkblayout all next"

        # Clipboard
        ''$mainMod, C, exec, cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy''

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mainMod, Print, exec, grim - | wl-copy"
        "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Theme
        "$mainMod, T, exec, kernix-rofi-theme-select"
        "$mainMod SHIFT, T, exec, kernix-theme-next"
        "$mainMod, W, exec, kernix-rofi-wallpaper-select"
        "$mainMod SHIFT, W, exec, kernix-wallpaper-next"

        # Brightness
        ", XF86MonBrightnessUp, exec, brightness-control up"
        ", XF86MonBrightnessDown, exec, brightness-control down"

        # Volume / Media
        ", XF86AudioRaiseVolume, exec, volume-control up"
        ", XF86AudioLowerVolume, exec, volume-control down"
        ", XF86AudioMute, exec, volume-control mute"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };

    # Theme override (sourced last, colors overwrite defaults)
    extraConfig = ''
      source = ~/.config/hypr/active-theme.conf
    '';
  };

  # XDG portal -- route interfaces to the correct backend
  xdg.portal = {
    enable = true;
    config = {
      hyprland = {
        default = ["hyprland" "gtk"];
      };
      common = {
        default = ["gtk"];
      };
    };
  };

  # Create empty stubs so Hyprland doesn't error before first theme switch
  home.activation.hyprlandThemeStubs = config.lib.dag.entryAfter ["linkGeneration"] ''
    mkdir -p "$HOME/.config/hypr/wallpapers"
    [ -e "$HOME/.config/hypr/active-theme.conf" ] || touch "$HOME/.config/hypr/active-theme.conf"
  '';

  # Reload Hyprland after HM deploys a new config
  home.activation.hyprlandReload = lib.hm.dag.entryAfter ["linkGeneration"] ''
    if command -v hyprctl &>/dev/null && hyprctl monitors &>/dev/null 2>&1; then
      hyprctl reload &>/dev/null || true
    fi
  '';
}
