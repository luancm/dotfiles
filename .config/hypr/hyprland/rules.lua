-- Window rules

-- Ignore maximize requests from all apps.
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Floating helpers / dialogs
hl.window_rule({
    name  = "float-calculator",
    match = { class = "^(org.gnome.Calculator|gnome-calculator)$" },
    float = true,
})

hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name  = "float-blueman",
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name  = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name  = "float-portal-gtk",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
})

hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = "^(Open File|Save File|Open Folder|Save As)$" },
    float = true,
})

hl.window_rule({
    name  = "float-pinentry",
    match = { class = "^(pinentry|Pinentry|gcr-prompter|polkit-gnome-authentication-agent-1)$" },
    float = true,
})

-- chordwatch (Wine/qode.exe): small always-on-top util, keep floating + pinned
hl.window_rule({
    name  = "chordwatch-float",
    match = { class = "^(qode%.exe)$" },
    float = true,
})

hl.window_rule({
    name  = "chordwatch-pin",
    match = { class = "^(qode%.exe)$" },
    pin = true,
})
