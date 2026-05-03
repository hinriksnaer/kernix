# Brightness control with OSD notification
# Usage: brightness-control [up|down]

action="${1:-}"

case "$action" in
    up)
        brightnessctl set 5%+
        ;;
    down)
        brightnessctl set 5%-
        ;;
    *)
        echo "Usage: brightness-control [up|down]"
        exit 1
        ;;
esac

# Get current brightness percentage
brightness_percent="$(brightnessctl -m | awk -F, '{gsub(/%/, "", $4); print $4}')"

# Determine icon
if [[ "$brightness_percent" -lt 33 ]]; then
    icon="display-brightness-low"
elif [[ "$brightness_percent" -lt 66 ]]; then
    icon="display-brightness-medium"
else
    icon="display-brightness-high"
fi

# Send notification with progress bar hint
notify-send -t 1500 \
    -h string:x-canonical-private-synchronous:brightness \
    -h "int:value:$brightness_percent" \
    -i "$icon" \
    -u low \
    "$brightness_percent%" ""
