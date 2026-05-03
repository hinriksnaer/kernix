#!/usr/bin/env fish
# Apply theme to all running neovim instances via RPC.
# Called by hawker-theme-apply as a script hook.
# Usage: hawker-theme-apply-neovim <theme-name> <theme-path>

if test (count $argv) -lt 2
    exit 1
end

set theme_path $argv[2]
set nvim_source "$theme_path/neovim.lua"

if not test -f "$nvim_source"
    exit 1
end

set escaped_path (string replace -a "'" "\\'" "$nvim_source")
set lua_cmd "local ok, spec = pcall(dofile, '$escaped_path'); if ok and spec then for _, s in ipairs(spec) do if type(s) == 'table' and s.config then pcall(s.config, nil, s.opts or {}) end end end"

# Find neovim server sockets
set uid (id -u)
set found 0
for sock in /run/user/$uid/nvim.*.0 /tmp/nvim*/0
    if test -S "$sock"
        nvim --server "$sock" --remote-send ":lua $lua_cmd<CR>" >/dev/null 2>&1
        set found 1
    end
end

exit 0
