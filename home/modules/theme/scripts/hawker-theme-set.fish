#!/usr/bin/env fish
# Set a specific theme by name.
# Thin orchestrator: writes state, applies hooks, sets wallpaper.
# Usage: hawker-theme-set <theme-name>

if test (count $argv) -lt 1
    echo "Usage: hawker-theme-set <theme-name>"
    echo ""
    echo "Available themes:"
    hawker-theme-list
    exit 1
end

set theme_name (echo $argv[1] | string lower | string replace -a ' ' '-')

# Verify theme exists
if test -n "$HAWKER_PATH"; and test -d "$HAWKER_PATH/themes"
    set themes_dir "$HAWKER_PATH/themes"
else
    set themes_dir "$HOME/.local/share/hawker/themes"
end

if not test -d "$themes_dir/$theme_name"
    echo "Error: Theme '$theme_name' does not exist"
    echo ""
    echo "Available themes:"
    hawker-theme-list
    exit 1
end

# 1. Write global state
mkdir -p "$HOME/.config/hawker"
echo "$theme_name" > "$HOME/.config/hawker/current-theme"

# 2. Apply all hooks (streams output in real-time)
hawker-theme-apply $theme_name

# 3. Set wallpaper (if available)
if command -v hawker-wallpaper-set >/dev/null 2>&1
    hawker-wallpaper-set $theme_name >/dev/null 2>&1
end

# 4. Send notification (if available)
if command -v notify-send >/dev/null 2>&1
    set pretty_name (echo $theme_name | sed 's/-/ /g; s/\b\(.\)/\u\1/g')
    notify-send "Theme Changed" "Switched to: $pretty_name" -t 3000 2>/dev/null
end
