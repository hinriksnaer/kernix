# Refresh/reapply the current theme (useful after config changes)
# Usage: hawker-theme-refresh

current_theme="$(hawker-theme-current 2>/dev/null || true)"

if [[ -n "$current_theme" ]]; then
    echo "Refreshing theme: $current_theme"
    hawker-theme-set "$current_theme"
else
    echo "Error: No theme is currently set"
    echo "Run 'hawker-theme-set <theme-name>' first"
    exit 1
fi
