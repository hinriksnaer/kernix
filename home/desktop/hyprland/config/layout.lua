-- Layout -- dwindle, master, misc settings.
-- IS_HIDPI and TERMINAL_CLASS are injected by the Nix entry point.

hl.config({
    general = {
        layout = IS_HIDPI and "master" or "dwindle",
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "slave",
        mfact = 0.5,
        orientation = "center",
        slave_count_for_center_master = 0,
        center_master_fallback = "right",
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = true,
        disable_autoreload = false,
        anr_missed_pings = 3,
        enable_swallow = true,
        swallow_regex = "^(" .. TERMINAL_CLASS .. ")$",
    },
})
