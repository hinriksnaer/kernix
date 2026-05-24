-- Appearance -- general look, decoration, blur, shadow.
-- Theme colors are loaded last via active-theme.lua and override col.* values.

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,

        -- Default colors (overridden by theme)
        col = {
            active_border = "rgba(ff6a1fee)",
            inactive_border = "rgba(595959aa)",
        },
    },

    decoration = {
        rounding = 4,
        active_opacity = 1.0,
        inactive_opacity = 0.95,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.15,

        shadow = {
            enabled = true,
            range = 2,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 8,
            passes = 1,
            new_optimizations = true,
            xray = false,
            noise = 0.0117,
            contrast = 0.8916,
            brightness = 0.8172,
        },
    },
})
