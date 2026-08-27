# Waybar status bar.
# Theme CSS loaded at runtime via @import (swapped by kernix-theme-set).
{
  config,
  lib,
  host,
  ...
}: let
  enabledMonitors = builtins.filter (m: m.enabled) host.desktop.monitors;
  primaryMonitor = lib.findFirst (m: m.primary) (builtins.head enabledMonitors) enabledMonitors;
  terminal = host.terminal;
  gpu = host.gpu;
  isNvidia = gpu == "nvidia";
in
  lib.mkIf host.desktop.enable {
    kernix.theme.hooks = ["waybar"];

    programs.waybar = {
      enable = true;

      settings.mainBar =
        {
          output = primaryMonitor.name;
          reload_style_on_change = true;
          layer = "top";
          position = "top";
          spacing = 0;
          height = 32;

          modules-left = ["custom/kernix" "hyprland/workspaces"];
          modules-center = ["clock"];
          modules-right =
            ["group/stats"]
            ++ [
              "custom/battery-icon"
              "battery"
              "group/tray-drawer"
              "custom/power"
            ];

          "hyprland/workspaces" = {
            on-click = "activate";
            format = "{icon}";
            format-icons = {
              default = "";
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              active = "󱓻";
            };
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
          };

          "custom/kernix" = {
            format = "";
            on-click = "rofi -show drun";
            on-click-right = terminal;
            tooltip-format = "Kernix Menu\n\nSuper + Space";
          };

          clock = {
            timezone = "";
            format = "{:%H:%M}";
            format-alt = "{:%a, %b %d, %Y  %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            interval = 60;
          };

          "group/tray-drawer" = {
            orientation = "inherit";
            drawer = {
              transition-duration = 300;
              transition-left-to-right = false;
              children-class = "tray-child";
            };
            modules = ["custom/tray-toggle" "tray"];
          };
          "custom/tray-toggle" = {
            format = "󰅁";
            tooltip-format = "System Tray";
          };
          tray = {
            spacing = 8;
          };

          "custom/battery-icon" = {
            exec = ''
              while true; do
                cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
                status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
                if [ -z "$cap" ]; then
                  echo ""
                elif [ "$status" = "Charging" ]; then
                  echo "󰂄"
                elif [ "$cap" -le 10 ]; then
                  echo "󰁺"
                elif [ "$cap" -le 30 ]; then
                  echo "󰁻"
                elif [ "$cap" -le 60 ]; then
                  echo "󰁽"
                elif [ "$cap" -le 90 ]; then
                  echo "󰁿"
                else
                  echo "󰁹"
                fi
                sleep 30
              done
            '';
            tooltip = false;
          };
          battery = {
            interval = 30;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}%";
            format-charging = "{capacity}%";
            tooltip-format = "{timeTo} ({capacity}%)";
          };

          "group/stats" = {
            orientation = "inherit";
            modules =
              ["custom/cpu-icon" "cpu" "custom/temp-icon" "temperature"]
              ++ lib.optional isNvidia "custom/gpu-icon"
              ++ lib.optional isNvidia "custom/gpu-usage"
              ++ lib.optional isNvidia "custom/gpu-temp-icon"
              ++ lib.optional isNvidia "custom/gpu-temp"
              ++ ["custom/mem-icon" "memory"];
          };
          "custom/cpu-icon" = {
            format = "󰍛";
            tooltip = false;
          };
          cpu = {
            interval = 2;
            format = "{usage}%";
            tooltip-format = "CPU: {usage}%\nLoad: {load}";
            on-click = "${terminal} -e btop";
          };
          "custom/temp-icon" = {
            format = "󰔏";
            tooltip = false;
          };
          temperature = {
            interval = 2;
            critical-threshold = 75;
            format = "{temperatureC}°";
            format-critical = "{temperatureC}°";
            tooltip-format = "CPU Temp: {temperatureC}°C";
          };
          "custom/mem-icon" = {
            format = "󰘚";
            tooltip = false;
          };
          memory = {
            interval = 2;
            format = "{percentage}%";
            tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G ({percentage}%)";
            on-click = "${terminal} -e btop";
          };

          "custom/power" = {
            format = "⏻";
            tooltip-format = "Power Menu";
            on-click = "power-menu";
          };
        }
        // lib.optionalAttrs isNvidia {
          "custom/gpu-icon" = {
            format = "󰢮";
            tooltip = false;
          };
          "custom/gpu-usage" = {
            exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n 1";
            interval = 2;
            format = "{}%";
            tooltip-format = "GPU Usage";
            on-click = "${terminal} -e btop";
          };
          "custom/gpu-temp-icon" = {
            format = "󰔏";
            tooltip = false;
          };
          "custom/gpu-temp" = {
            exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n 1";
            interval = 2;
            format = "{}°";
            tooltip-format = "GPU Temperature";
            on-click = "${terminal} -e btop";
          };
        };

      # Theme CSS imported at runtime (symlinked by kernix-theme-apply)
      # Use absolute path so the @import resolves correctly from the nix store.
      style =
        builtins.replaceStrings
        ["@import \"theme.css\";"]
        ["@import url(\"${config.home.homeDirectory}/.config/waybar/theme.css\");"]
        (builtins.readFile ./config/style.css);
    };
  }
