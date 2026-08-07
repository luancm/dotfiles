-- Input config + keybinds.
-- Returned as a function so it can receive shared vars from hyprland.lua.

local function M(vars)
    local mainMod     = vars.mainMod
    local terminal    = vars.terminal
    local fileManager = vars.fileManager
    local browser     = vars.browser
    local menu        = vars.menu

    -------------
    ---- INPUT ----
    -------------

    hl.config({
        input = {
            kb_layout  = "us",
            kb_variant = "intl",
            numlock_by_default = true,
            repeat_delay = 250,
            repeat_rate  = 35,
            touchpad = {
                natural_scroll       = true,
                disable_while_typing = true,
                clickfinger_behavior = true,
                scroll_factor        = 0.5,
            },
            special_fallthrough = true,
            follow_mouse = 1,
        },
        binds = {
            scroll_event_delay = 0,
        },
    })

    ---------------
    ---- KEYBINDS ----
    ---------------

    -- Apps
    hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
    hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
    hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
    hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
    hl.bind(mainMod .. " + Q", hl.dsp.window.close())

    -- Color picker
    hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

    -- Clipboard history (cliphist via Walker service socket)
    hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | walker --dmenu | cliphist decode | wl-copy"))

    -- Screenshots: region (slurp) and full outputs
    hl.bind("Print",            hl.dsp.exec_cmd('grim -g "$(slurp)" -t ppm - | satty --filename -'))
    hl.bind("ALT + CTRL + 4",   hl.dsp.exec_cmd('grim -g "$(slurp)" -t ppm - | satty --filename -'))
    hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.exec_cmd('grim -g "$(slurp)" -t ppm - | satty --filename -'))
    hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd('grim -t ppm - | satty --filename -'))

    -- Session
    hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session"))
    hl.bind(mainMod .. " + M",        hl.dsp.exec_cmd("wlogout"))

    -- Window management
    hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

    -- Special/scratchpad workspace
    hl.bind(mainMod .. " + minus",        hl.dsp.workspace.toggle_special("magic"))
    hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:magic" }))

    -- Fullscreen (0) vs maximize (1)
    hl.bind(mainMod .. " + F", function() hl.window.fullscreen({ mode = "fullscreen", action = "toggle" }) end)
    hl.bind(mainMod .. " + D", function() hl.window.fullscreen({ mode = "maximized", action = "toggle" }) end)

    -- Alt-Tab cycle (no typed Lua wrapper; route through hyprctl dispatch).
    hl.bind("ALT + Tab", function()
        hl.dsp.exec_cmd("hyprctl dispatch cyclenext")
        hl.dsp.exec_cmd("hyprctl dispatch bringactivetotop")
    end)

    -- Move focus with mainMod + arrow keys / hjkl
    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
    hl.bind(mainMod .. " + h",     hl.dsp.focus({ direction = "left"  }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + l",     hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
    hl.bind(mainMod .. " + k",     hl.dsp.focus({ direction = "up"    }))
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))
    hl.bind(mainMod .. " + j",     hl.dsp.focus({ direction = "down"  }))

    -- Switch workspaces with mainMod + [0-9]
    for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Swap windows directionally (tiled) with mainMod + SHIFT + hjkl
    hl.bind(mainMod .. " + SHIFT + H",     function() hl.window.swap({ direction = "left"  }) end)
    hl.bind(mainMod .. " + SHIFT + L",     function() hl.window.swap({ direction = "right" }) end)
    hl.bind(mainMod .. " + SHIFT + K",     function() hl.window.swap({ direction = "up"    }) end)
    hl.bind(mainMod .. " + SHIFT + J",     function() hl.window.swap({ direction = "down"  }) end)
    hl.bind(mainMod .. " + SHIFT + left",  function() hl.window.swap({ direction = "left"  }) end)
    hl.bind(mainMod .. " + SHIFT + right", function() hl.window.swap({ direction = "right" }) end)
    hl.bind(mainMod .. " + SHIFT + up",    function() hl.window.swap({ direction = "up"    }) end)
    hl.bind(mainMod .. " + SHIFT + down",  function() hl.window.swap({ direction = "down"  }) end)

    -- Move/resize windows with mainMod + LMB/RMB and dragging
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Window split toggle
    hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

    -- Window split ratio
    hl.bind(mainMod .. " + Equal",    hl.dsp.layout("splitratio +0.1"))
    hl.bind(mainMod .. " + Semicolon", hl.dsp.layout("splitratio -0.1"))
    hl.bind(mainMod .. " + Apostrophe", hl.dsp.layout("splitratio +0.1"))

    -- Multimedia: volume + brightness + playerctl
    hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),      { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),           { locked = true, repeating = true })
    hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),          { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),        { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                       { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                       { locked = true, repeating = true })
    hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                                 { locked = true })
    hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                       { locked = true })
    hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                                   { locked = true })
    hl.bind("XF86AudioStop",         hl.dsp.exec_cmd("playerctl stop"),                                       { locked = true })
end

return M
