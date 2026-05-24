-- Window rules.
-- TERMINAL_CLASS is injected by the Nix entry point.

hl.window_rule({
    name = "file-dialogs",
    match = { title = "^(Open File|Save File|Open Folder)$" },
    float = true,
})

hl.window_rule({
    name = "floating-utils",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|mpv|polkit-gnome-authentication-agent-1)$" },
    float = true,
})

hl.window_rule({
    name = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
})

hl.window_rule({
    name = "terminal-opacity",
    match = { class = "^(" .. TERMINAL_CLASS .. ")$" },
    opacity = "0.95 0.85",
})

hl.window_rule({
    name = "comms-workspace",
    match = { class = "^(discord|Slack)$" },
    workspace = "3",
})
