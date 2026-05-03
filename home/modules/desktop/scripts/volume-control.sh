# Volume control with OSD notification
# Usage: volume-control [up|down|mute]

action="${1:-}"
active_sink="@DEFAULT_AUDIO_SINK@"

case "$action" in
    up)
        wpctl set-volume "$active_sink" 5%+
        ;;
    down)
        wpctl set-volume "$active_sink" 5%-
        ;;
    mute)
        wpctl set-mute "$active_sink" toggle
        ;;
    *)
        echo "Usage: volume-control [up|down|mute]"
        exit 1
        ;;
esac

# Get current volume and mute status
volume_info="$(wpctl get-volume "$active_sink")"
volume_value="$(echo "$volume_info" | awk '{print $2}')"
volume_percent="$(awk "BEGIN {printf \"%.0f\", $volume_value * 100}")"
if echo "$volume_info" | grep -q "MUTED"; then
    is_muted="yes"
else
    is_muted="no"
fi

# Determine icon
if [[ "$is_muted" == "yes" ]]; then
    icon="audio-volume-muted"
elif [[ "$volume_percent" -lt 33 ]]; then
    icon="audio-volume-low"
elif [[ "$volume_percent" -lt 66 ]]; then
    icon="audio-volume-medium"
else
    icon="audio-volume-high"
fi

# Send notification with progress bar hint
if [[ "$is_muted" == "yes" ]]; then
    notify-send -t 1500 \
        -h string:x-canonical-private-synchronous:volume \
        -h int:value:0 \
        -i "$icon" \
        -u low \
        "Volume" "Muted"
else
    notify-send -t 1500 \
        -h string:x-canonical-private-synchronous:volume \
        -h "int:value:$volume_percent" \
        -i "$icon" \
        -u low \
        "$volume_percent%" ""
fi
