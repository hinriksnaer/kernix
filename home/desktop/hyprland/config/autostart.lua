-- Autostart -- apps launched on compositor startup.
-- BAR_START, NOTIFICATIONS_START, HAS_TV are injected by the Nix entry point.

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd(BAR_START)
    hl.exec_cmd(NOTIFICATIONS_START)
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("swaybg -i " .. os.getenv("HOME") .. "/.config/hypr/wallpapers/current -m fill")

    -- Delayed theme refresh (ensure all stubs exist first)
    hl.timer(function()
        hl.exec_cmd("kernix-theme-refresh 2>/dev/null || true")
    end, { timeout = 2000, type = "oneshot" })

    if HAS_TV then
        hl.exec_cmd("bitwarden")
    end
end)
