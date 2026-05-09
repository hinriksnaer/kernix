# Audio output selector via rofi
# Sets the default sink used by volume-control and all audio
# Usage: rofi-audio-select

# Parse sinks from wpctl status in a single awk pass
declare -a sink_ids sink_names
current_index=-1
i=0

while IFS=$'\t' read -r sid sname is_default; do
    sink_ids+=("$sid")
    sink_names+=("$sname")
    if [[ "$is_default" == "1" ]]; then
        current_index=$i
    fi
    i=$((i + 1))
done < <(wpctl status | awk '
    /Sinks:/ { found=1; next }
    found && !/^[[:space:]]*[│]/ { found=0 }
    found && /[0-9]+\./ {
        is_default = ($0 ~ /\*/) ? "1" : "0"
        for (j=1; j<=NF; j++) {
            if ($j ~ /^[0-9]+\.$/) {
                id = substr($j, 1, length($j)-1)
                sub(/\[vol:.*/, "")
                match($0, /[0-9]+\. /)
                name = substr($0, RSTART+RLENGTH)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
                print id "\t" name "\t" is_default
                break
            }
        }
    }
')

if [[ ${#sink_names[@]} -eq 0 ]]; then
    notify-send -t 3000 -i audio-card "Audio Output" "No audio sinks found"
    exit 1
fi

# Build display list with current marker
display_list=()
for j in "${!sink_names[@]}"; do
    if [[ $j -eq $current_index ]]; then
        display_list+=("* ${sink_names[$j]}")
    else
        display_list+=("  ${sink_names[$j]}")
    fi
done

# Show rofi picker
rofi_args=(-dmenu -i -p "Audio Output" -no-custom)
rofi_args+=(-theme-str 'window {width: 550px;} listview {lines: 6;}')
if [[ $current_index -ge 0 ]]; then
    rofi_args+=(-selected-row "$current_index")
fi

selected="$(printf '%s\n' "${display_list[@]}" | rofi "${rofi_args[@]}" || true)"

if [[ -z "$selected" ]]; then
    exit 0
fi

# Clean selection (strip marker prefix)
selected_name="${selected#\* }"
selected_name="${selected_name#  }"

# Find matching sink and set as default
for j in "${!sink_names[@]}"; do
    if [[ "${sink_names[$j]}" == "$selected_name" ]]; then
        wpctl set-default "${sink_ids[$j]}"
        notify-send -t 2000 \
            -h string:x-canonical-private-synchronous:audio-select \
            -i audio-card \
            "Audio Output" "Switched to ${sink_names[$j]}"
        break
    fi
done
