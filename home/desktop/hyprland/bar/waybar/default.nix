# Waybar status bar.
# Theme CSS loaded at runtime via @import (swapped by kernix-theme-set).
{
  config,
  lib,
  settings,
  ...
}: let
  primaryMonitor = lib.findFirst (m: m.primary) (builtins.head config.monitors) config.monitors;
  terminal = settings.terminal;
in {
  kernix.theme.hooks = ["waybar"];

  programs.waybar = {
    enable = true;

    settings.mainBar = {
      output = primaryMonitor.name;
      reload_style_on_change = true;
      layer = "top";
      position = "top";
      spacing = 0;
      height = 26;

      modules-left = ["custom/kernix" "hyprland/workspaces"];
      modules-center = ["clock"];
      modules-right = [
        "group/hardware-cpu"
        "group/hardware-gpu"
        "group/hardware-ram"
        "group/tray-expander"
        "bluetooth"
        "network"
        "backlight"
        "pulseaudio"
        "battery"
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
        format = "  {:%H:%M}";
        format-alt = "  {:%a, %b %d, %Y %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        interval = 60;
      };

      # Tray expander group
      "group/tray-expander" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 300;
          transition-left-to-right = false;
          children-class = "tray-child";
        };
        modules = ["custom/tray-icon" "tray"];
      };
      "custom/tray-icon" = {
        format = "󱊔";
        tooltip-format = "System Tray";
      };
      tray = {
        spacing = 8;
      };

      bluetooth = {
        format = "󰂯";
        format-connected = "󰂱 {num_connections}";
        format-disabled = "󰂲";
        tooltip-format = "Bluetooth {status}";
        tooltip-format-connected = "{device_alias} ({device_address})";
        on-click = "blueman-manager";
      };

      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "󰈀";
        format-disconnected = "Disconnected ⚠";
        tooltip-format = "{essid} ({signalStrength}%)";
        on-click = "nm-connection-editor";
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = ["" "" "" "" "" "" "" "" ""];
        scroll-step = 5;
        on-scroll-up = "brightness-control up";
        on-scroll-down = "brightness-control down";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "  Muted";
        format-icons = {
          default = ["" "" ""];
        };
        on-click = "pavucontrol";
        on-click-right = "pamixer -t";
        scroll-step = 5;
      };

      battery = {
        interval = 30;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-icons = ["" "" "" "" ""];
        tooltip-format = "{timeTo} ({capacity}%)";
      };

      # CPU hardware group
      "group/hardware-cpu" = {
        orientation = "inherit";
        modules = ["custom/cpu-icon" "cpu" "temperature"];
      };
      "custom/cpu-icon" = {
        format = "󰍛";
        tooltip = false;
      };
      cpu = {
        interval = 2;
        format = "{usage}%";
        tooltip-format = "CPU Usage: {usage}%\nLoad: {load}";
        on-click = "${terminal} -e btop";
      };
      temperature = {
        interval = 2;
        hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
        input-filename = "temp1_input";
        critical-threshold = 75;
        format = "{temperatureC}°";
        format-critical = " {temperatureC}°";
        tooltip-format = "CPU Temp: {temperatureC}°C";
        on-click = "${terminal} -e btop";
      };

      # GPU hardware group
      "group/hardware-gpu" = {
        orientation = "inherit";
        modules = ["custom/gpu-icon" "custom/gpu-usage" "custom/gpu-temp"];
      };
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
      "custom/gpu-temp" = {
        exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n 1";
        interval = 2;
        format = "{}°";
        tooltip-format = "GPU Temperature";
        on-click = "${terminal} -e btop";
      };

      # RAM hardware group
      "group/hardware-ram" = {
        orientation = "inherit";
        modules = ["custom/ram-icon" "memory"];
      };
      "custom/ram-icon" = {
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
    };

    # Theme CSS imported at runtime (symlinked by kernix-theme-apply)
    style = builtins.readFile ./config/style.css;
  };
}
