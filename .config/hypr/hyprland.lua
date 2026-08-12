-- Hyprland config (Lua, >= 0.55)
-- Converted from .conf format. Each section is a required module under hyprland/.

-- Shared variables used by keybinds and autostart modules.
local mainMod     = "SUPER"
local terminal    = "ghostty"
local fileManager = "dolphin"
local browser     = "firefox"
-- Launcher toggle (Vicinae deeplink; also accepts raycast://).
local menu        = "vicinae vicinae://toggle"

-- Export for sub-modules via a shared table.
local vars = {
    mainMod     = mainMod,
    terminal    = terminal,
    fileManager = fileManager,
    browser     = browser,
    menu        = menu,
}

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "highrr",
    position = "auto",
    scale    = 1,
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-------------------
---- SUB-MODULES ----
-------------------

require("hyprland.autostart")
require("hyprland.looknfeel")
require("hyprland.rules")
require("hyprland.keybinds")(vars)
