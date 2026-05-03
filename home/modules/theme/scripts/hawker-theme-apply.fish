#!/usr/bin/env fish
# Unified theme hook processor -- applies theme to all registered apps.
# Reads hook definitions from ~/.config/hawker/theme-hooks.d/ and processes
# them in sorted order. Handles symlink, hyprland, config-rewrite, and script types.
# Usage: hawker-theme-apply <theme-name>

set hooks_dir "$HOME/.config/hawker/theme-hooks.d"

# Output helpers
set C_RESET '\033[0m'
set C_GREEN '\033[0;32m'
set C_YELLOW '\033[0;33m'
set C_RED '\033[0;31m'

function success; echo -e "$C_GREEN✓$C_RESET $argv"; end
function warning; echo -e "$C_YELLOW⊘$C_RESET $argv"; end
function error; echo -e "$C_RED✗$C_RESET $argv"; end

if test (count $argv) -lt 1
    echo "Usage: hawker-theme-apply <theme-name>"
    exit 1
end

# Find themes directory
if test -n "$HAWKER_PATH"; and test -d "$HAWKER_PATH/themes"
    set themes_dir "$HAWKER_PATH/themes"
else
    set themes_dir "$HOME/.local/share/hawker/themes"
end

set theme_name (echo $argv[1] | string lower | string replace -a ' ' '-')

if not test -d "$themes_dir/$theme_name"
    error "Theme '$theme_name' does not exist"
    exit 1
end

set theme_path "$themes_dir/$theme_name"
set applied_count 0
set skipped_count 0
set reload_names
set reload_commands

# Process hook files (sorted alphanumerically)
if not test -d "$hooks_dir"
    warning "No theme hooks directory at $hooks_dir"
    echo "0:0"
    exit 0
end

for hook_file in $hooks_dir/*
    if not test -f "$hook_file"
        continue
    end

    set hook_name (basename $hook_file | sed 's/^[0-9]*-//')
    set source_file ""
    set target_path ""
    set reload_cmd ""
    set hook_type "symlink"
    set config_key ""
    set hook_script ""

    # Parse hook file
    for line in (cat $hook_file)
        set line (string trim $line)
        if test -z "$line"; or string match -q '#*' $line
            continue
        end
        set k (echo $line | string split '=' | head -1 | string trim)
        set val (echo $line | string replace "$k=" '' | string trim)
        switch $k
            case source
                set source_file $val
            case target
                set target_path (eval echo $val)
            case reload
                set reload_cmd $val
            case type
                set hook_type $val
            case key
                set config_key $val
            case script
                set hook_script $val
        end
    end

    # ── symlink type ──
    if test "$hook_type" = "symlink"
        if test -z "$source_file"; or test -z "$target_path"
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name (missing source or target)"
            continue
        end
        if test -f "$theme_path/$source_file"
            mkdir -p (dirname $target_path) 2>/dev/null
            ln -sf "$theme_path/$source_file" "$target_path"
            set applied_count (math $applied_count + 1)
            success "Applied $hook_name"
        else
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name ($source_file not in theme)"
        end

    # ── hyprland type ──
    else if test "$hook_type" = "hyprland"
        if test -f "$theme_path/hyprland.conf"
            set active_theme_conf "$HOME/.config/hypr/active-theme.conf"
            printf '%s\n' \
                '# Active Hyprland Theme (runtime-generated)' \
                '# Managed by hawker-theme-apply' \
                "# theme: $theme_name" \
                '' \
                > $active_theme_conf
            grep '^\$' "$theme_path/hyprland.conf" >> $active_theme_conf 2>/dev/null
            sed -n '/^general {/,/^}/p' "$theme_path/hyprland.conf" >> $active_theme_conf 2>/dev/null
            sed -n '/^group {/,/^}/p' "$theme_path/hyprland.conf" >> $active_theme_conf 2>/dev/null
            set applied_count (math $applied_count + 1)
            success "Applied $hook_name"
        else
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name (no hyprland.conf in theme)"
        end

    # ── config-rewrite type ──
    else if test "$hook_type" = "config-rewrite"
        if test -n "$target_path"; and test -n "$config_key"
            if test -f "$target_path"
                sed -i "s/\"$config_key\": *\"[^\"]*\"/\"$config_key\": \"$theme_name\"/" "$target_path"
                set applied_count (math $applied_count + 1)
                success "Applied $hook_name"
            else
                set skipped_count (math $skipped_count + 1)
                warning "Skipped $hook_name ($target_path not found)"
            end
        else
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name (missing target or key)"
        end

    # ── script type ──
    else if test "$hook_type" = "script"
        if test -z "$hook_script"
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name (no script specified)"
            continue
        end
        # Skip if script not available or source file specified but missing
        if not command -v "$hook_script" >/dev/null 2>&1
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name ($hook_script not found)"
            continue
        end
        if test -n "$source_file"; and not test -f "$theme_path/$source_file"
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name ($source_file not in theme)"
            continue
        end
        $hook_script "$theme_name" "$theme_path"
        if test $status -eq 0
            set applied_count (math $applied_count + 1)
            success "Applied $hook_name"
        else
            set skipped_count (math $skipped_count + 1)
            warning "Skipped $hook_name (script failed)"
        end

    else
        set skipped_count (math $skipped_count + 1)
        warning "Skipped $hook_name (unknown type: $hook_type)"
    end

    # Queue reload command
    if test -n "$reload_cmd"
        set reload_names $reload_names "$hook_name"
        set reload_commands $reload_commands "$reload_cmd"
    end
end

# Execute reload commands
if test (count $reload_commands) -gt 0
    echo ""
    for i in (seq (count $reload_commands))
        set cmd $reload_commands[$i]
        set name $reload_names[$i]
        eval $cmd >/dev/null 2>&1 &
        disown 2>/dev/null
        success "Reloaded $name"
    end
end

# Summary
set pretty_name (echo $theme_name | sed 's/-/ /g; s/\b\(.\)/\u\1/g')
echo ""
echo "╭────────────────────────────────────────╮"
echo "│ Theme: $pretty_name"
echo "│ Applied: $applied_count  •  Skipped: $skipped_count"
echo "╰────────────────────────────────────────╯"
echo ""
