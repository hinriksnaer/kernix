-- Keybindings.
-- TERMINAL, TERMINAL_EXEC, LAUNCHER_RUN, LAUNCHER_CLIPBOARD, LAUNCHER_AUDIO,
-- LAUNCHER_POWER, LAUNCHER_THEME, LAUNCHER_WALLPAPER are injected by the Nix entry point.

local mainMod = "SUPER"

-- Emergency
hl.bind("CTRL + ALT + BackSpace", hl.dsp.exit())

-- Applications
hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(TERMINAL))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.workspace.toggle_special("emergency"))
hl.bind(mainMod .. " + B",              hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(TERMINAL .. " " .. TERMINAL_EXEC .. " yazi"))
hl.bind(mainMod .. " + Space",          hl.dsp.exec_cmd(LAUNCHER_RUN))
hl.bind(mainMod .. " + Escape",         hl.dsp.exec_cmd("hyprlock"))

-- Window management
hl.bind(mainMod .. " + Q",              hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E",      hl.dsp.exit())
hl.bind(mainMod .. " + V",              hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",              hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P",              hl.dsp.window.pseudo())
hl.bind(mainMod .. " + ALT + R",        hl.dsp.layout("togglesplit"))

-- Layout toggle (dwindle <-> master)
hl.bind(mainMod .. " + ALT + Space", function()
    local current = hl.get_config("general.layout")
    local next_layout = current == "dwindle" and "master" or "dwindle"
    hl.config({ general = { layout = next_layout } })
end)

-- Focus (vim)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Swap windows
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.swap({ direction = "down" }))

-- Resize windows
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 50,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0,   y = 50, relative = true }), { repeating = true })

-- Move windows
hl.bind(mainMod .. " + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.window.move({ direction = "down" }))

-- Workspaces (loop instead of 20 lines)
for i = 0, 9 do
    local ws = i == 0 and 10 or i
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = ws }))
end
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- Navigate workspaces
hl.bind(mainMod .. " + bracketleft",         hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + bracketright",        hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + bracketright",hl.dsp.window.move({ workspace = "e+1" }))

-- Mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Keyboard layout
hl.bind(mainMod .. " + CTRL + Space", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Clipboard
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(LAUNCHER_CLIPBOARD))

-- Screenshots
hl.bind("Print",                    hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. " + Print",      hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mainMod .. " + SHIFT + S",  hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Audio
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(LAUNCHER_AUDIO))

-- Theme
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd(LAUNCHER_THEME))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("kernix-theme-next"))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(LAUNCHER_WALLPAPER))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("kernix-wallpaper-next"))

-- Volume (repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volume-control up"),   { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volume-control down"), { repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("volume-control mute"), { repeating = true })

-- Brightness (repeating)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightness-control up"),   { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightness-control down"), { repeating = true })

-- TV toggle: enable/disable the TV as a second monitor.
-- When enabled: 3840x2160@60, 10-bit HDR, positioned to the left of the main display.
-- Uses hl.get_monitors() to check if TV is currently active (disabled monitors
-- are excluded from the list, so absent = disabled).
if HAS_TV then
    hl.bind(mainMod .. " + D", function()
        local monitors = hl.get_monitors()
        local tv_on = false
        for _, m in ipairs(monitors) do
            if m.name == TV_OUTPUT then
                tv_on = true
                break
            end
        end
        if tv_on then
            hl.monitor({ output = TV_OUTPUT, disabled = true })
        else
            hl.monitor({ output = TV_OUTPUT, disabled = false, mode = "3840x2160@60", position = "auto-left", bitdepth = 10, cm = "hdr" })
        end
    end)
end

-- Couch mode (gamescope + Steam Deck UI on TV, with Sunshine streaming)
hl.bind(mainMod .. " + G",           hl.dsp.exec_cmd("kernix-couch tv"))   -- 3840x2160 (TV native)
hl.bind(mainMod .. " + SHIFT + G",   hl.dsp.exec_cmd("kernix-couch deck")) -- 1280x800  (Deck native)

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
