-- Look & feel: general, decoration, animations, layouts, misc, cursor.
-- Catppuccin Mocha colors applied here; the theme module is a pure data table.

local c = require("themes.catppuccin-mocha")

-- Spring physics curve for natural window open/close motion (0.56.0 default).
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
        col = {
            active_border   = c.mauve,
            inactive_border = c.surface1,
        },
        -- Edge snapping: drag a window to a screen edge to snap to
        -- half/quarter; respects existing gaps.
        snap = {
            enabled        = true,
            border_overlap = false,
            monitor_gap    = 10,
            window_gap     = 10,
            respect_gaps   = true,
        },
    },
    group = {
        col = {
            border_active   = c.mauve,
            border_inactive = c.surface1,
        },
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 2,
            render_power = 3,
            color        = "rgba(11111bee)",
        },
        blur = {
            enabled = true,
            size    = 3,
            passes  = 2,
            -- Blur special workspace + popups; xray skips hung opaque windows.
            xray    = true,
            special = true,
            popups  = true,
        },
        -- NEW 0.56.0: soft outer glow on active window border.
        glow = {
            enabled        = true,
            color          = c.mauve,
            color_inactive = c.surface1,
            range          = 8,
            render_power   = 4,
        },
        -- NEW 0.56.0: subtle motion blur trail while windows slide.
        motion_blur = {
            enabled = true,
            samples = 12,
        },
    },
    dwindle = {
        preserve_split = true,
        force_split = 0, -- 0 = follow cursor side when splitting
    },
    misc = {
        force_default_wallpaper    = -1,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        focus_on_activate          = true,
        vrr                        = 1,
        font_family                = "FiraCode Nerd Font",
        background_color           = c.base,
        -- Keep blur behind the hyprlock / hypridle lock screen.
        session_lock_blur          = true,
        -- Window swallowing: terminal hidden while GUI launched from it runs.
        enable_swallow             = true,
        swallow_regex              = "^(Ghostty)$",
    },
    cursor = {
        hide_on_key_press = true,
    },
})

----------------------
---- ANIMATIONS -----
----------------------

hl.config({ animations = { enabled = true } })

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
-- Spring physics for window open/close (natural bounce motion).
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",          style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",        style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- Slide workspace transitions (instant switches re-enabled with style = "slide").
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 4,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.5,  bezier = "linear",       style = "slide" })