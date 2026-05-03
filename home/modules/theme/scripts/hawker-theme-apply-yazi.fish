#!/usr/bin/env fish
# Apply theme to yazi by mapping hawker theme name to a yazi flavor.
# Called by hawker-theme-apply as a script hook.
# Usage: hawker-theme-apply-yazi <theme-name> <theme-path>

if test (count $argv) -lt 1
    exit 1
end

if not command -v yazi >/dev/null 2>&1
    exit 1
end

set theme_name $argv[1]
set theme_map "$HOME/.config/yazi/theme-map.conf"
set yazi_flavor ""

# Look up flavor mapping
if test -f "$theme_map"
    for line in (grep -v '^#' "$theme_map" | grep -v '^$')
        set parts (string split "=" $line)
        if test "$parts[1]" = "$theme_name"
            set yazi_flavor $parts[2]
            break
        end
    end
end

# Fallback if no mapping found
if test -z "$yazi_flavor"
    set yazi_flavor "catppuccin-mocha"
end

set theme_file "$HOME/.config/yazi/theme.toml"
printf '%s\n' \
    '# Yazi Theme for Hawker' \
    '# Managed by hawker-theme-apply - Do not edit manually' \
    '' \
    '[flavor]' \
    "use = \"$yazi_flavor\"" \
    > $theme_file 2>/dev/null

exit $status
