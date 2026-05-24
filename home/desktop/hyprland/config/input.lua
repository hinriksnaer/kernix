-- Input -- keyboard, mouse, cursor, xwayland.

hl.config({
    input = {
        kb_layout = "us,is",
        kb_options = "compose:caps",
        follow_mouse = 1,
        mouse_refocus = false,
        sensitivity = 0,
    },

    cursor = {
        no_hardware_cursors = true,
        hide_on_key_press = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})
