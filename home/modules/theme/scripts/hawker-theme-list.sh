# List all available themes in the themes directory
# Usage: hawker-theme-list

# Find themes directory
if [[ -n "${HAWKER_PATH:-}" ]] && [[ -d "$HAWKER_PATH/themes" ]]; then
    themes_dir="$HAWKER_PATH/themes"
elif [[ -d "$HOME/.local/share/hawker/themes" ]]; then
    themes_dir="$HOME/.local/share/hawker/themes"
else
    # Try to find relative to script location (for running from repo)
    themes_dir="${HAWKER_PATH:-}/themes"
fi

# Check if themes directory exists
if [[ ! -d "$themes_dir" ]]; then
    echo "Error: Themes directory not found" >&2
    exit 1
fi

# List all themes in the directory
for theme_dir in "$themes_dir"/*/; do
    [[ -d "$theme_dir" ]] || continue
    basename "$theme_dir"
done | sort
