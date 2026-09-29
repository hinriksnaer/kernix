-- Input -- keyboard, mouse, cursor, touchpad, xwayland.

hl.config({
    input = {
        kb_layout = "us,is",
        kb_options = "compose:caps",
        follow_mouse = 1,
        mouse_refocus = false,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        no_hardware_cursors = true,
        hide_on_key_press = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- Gestures -- trackpad workspace swipe.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
