# Volume control with OSD notification
# Usage: volume-control [up|down|mute]

# Serialize concurrent invocations to prevent race conditions
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/volume-control.lock"
flock -n 9 || exit 0

action="${1:-}"
active_sink="@DEFAULT_AUDIO_SINK@"

case "$action" in
    up)
        # Read current volume, snap up to next 5% increment, cap at 100%
        current="$(wpctl get-volume "$active_sink" | awk '{print $2}')"
        current_pct="$(awk "BEGIN {printf \"%.0f\", $current * 100}")"
        target=$(( ((current_pct / 5) + 1) * 5 ))
        if [ "$target" -gt 100 ]; then target=100; fi
        target_dec="$(awk "BEGIN {printf \"%.2f\", $target / 100}")"
        wpctl set-volume "$active_sink" "$target_dec"
        ;;
    down)
        # Read current volume, snap down to previous 5% increment, floor at 0%
        current="$(wpctl get-volume "$active_sink" | awk '{print $2}')"
        current_pct="$(awk "BEGIN {printf \"%.0f\", $current * 100}")"
        target=$(( ((current_pct - 1) / 5) * 5 ))
        if [ "$target" -lt 0 ]; then target=0; fi
        target_dec="$(awk "BEGIN {printf \"%.2f\", $target / 100}")"
        wpctl set-volume "$active_sink" "$target_dec"
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

# Release lock before sending notification (non-blocking)
exec 9>&-

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
