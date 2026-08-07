-- Autostart: exec-once commands run at Hyprland startup.

hl.on("hyprland.start", function()
    -- Secrets / privilege prompts
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("sh -c 'command -v hyprpolkitagent >/dev/null && exec hyprpolkitagent || exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'")

    -- Desktop portal (screenshare, file picker)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland.service xdg-desktop-portal.service")

    -- UI + wallpaper
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("sh -c 'if command -v wayle >/dev/null 2>&1; then exec wayle panel start; else exec waybar; fi'")
    hl.exec_cmd("swaync")

    -- Launcher stack
    hl.exec_cmd("elephant")
    hl.exec_cmd("walker --gapplication-service")

    -- Clipboard history (text + image)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- IME + idle
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("hypridle")
end)
