-- Minimal Hyprland Lua config mirroring the awesome/X11 setup:
-- everything floats, windows are snapped into a 3x2 grid (like set_to_slot in rc.lua)

local terminal = "kitty"

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
-- Qt apps (Telegram, keepassxc, birdtray) native wayland, xcb as fallback
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- reload via SIGUSR2 when running: a process restart tears down the systray
-- watcher and some apps never re-register their icon.
-- prefers the locally patched build (~/.local/src/waybar: active-highlight
-- flicker fix + lua-dispatch workspace clicks) over the repo package.
local function restart_waybar()
    hl.exec_cmd("pkill -SIGUSR2 -x waybar || { if [ -x ~/.local/bin/waybar ]; then exec ~/.local/bin/waybar; else exec waybar; fi; }")
end

-- restart waybar on hyprctl reload too, so its config changes apply on Mod+Ctrl+R
hl.on("config.reloaded", restart_waybar)

hl.on("hyprland.start", function()
    -- rebind the portals to this compositor instance, otherwise screenshots /
    -- screen sharing silently break after a hyprland restart
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal")
    restart_waybar()
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    -- thunderbird runs native wayland, always on, started hidden;
    -- Mod+T or the dimmed tasklist entry bring it up (no birdtray, no tray icon)
    hl.exec_cmd("~/.config/hypr/mail-keepalive.sh")
    hl.exec_cmd("Telegram -startintray")
    -- clipboard history collectors for SUPER+V
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- restart thunderbird if it ever exits or crashes
hl.timer(function()
    hl.exec_cmd("~/.config/hypr/mail-keepalive.sh")
end, { timeout = 30000, type = "repeat" })

hl.config({
    general = {
        border_size = 1,
        gaps_in     = 0,
        gaps_out    = 0,
        col = {
            active_border   = "rgb(535d6c)",
            inactive_border = "rgb(000000)",
        },
    },

    decoration = {
        rounding = 0,
        blur     = { enabled = false },
        shadow   = { enabled = false },
    },

    animations = {
        enabled = false,
    },

    -- no update news / donation popups on start
    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color        = "rgb(000000)",
        -- wake the screen on input while locked with dpms off
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },

    cursor = {
        -- don't teleport the mouse into windows on focus changes
        no_warps = true,
    },

    input = {
        -- same layout as /etc/X11/xorg.conf.d/00-keyboard.conf (hyprland does not read it)
        kb_layout          = "de",
        kb_model           = "pc105",
        -- xset r rate 200 30; per-key repeat off for Esc (xset -r 9) needs keyd instead
        repeat_delay       = 200,
        repeat_rate        = 30,
        numlock_by_default = true,
        follow_mouse       = 1,
    },
})

-- floating-only, like awesome's floating layout
hl.window_rule({
    name  = "float-everything",
    match = { class = ".*" },
    float = true,
})

-- no persistent workspace rules: waybar's left tag list pins 1-3 itself, and
-- server-persistent workspaces would defeat active-only in the center tasklist

-- manual tile: 3x2 grid, like set_to_slot in rc.lua
local function workarea(mon)
    local r = mon.reserved
    local left, top, right, bottom = 0, 0, 0, 0
    if type(r) == "table" then
        left   = r[1] or r.left or 0
        top    = r[2] or r.top or 0
        right  = r[3] or r.right or 0
        bottom = r[4] or r.bottom or 0
    elseif type(r) == "number" then
        left, top, right, bottom = r, r, r, r
    end
    local w = math.floor(mon.width / mon.scale) - left - right
    local h = math.floor(mon.height / mon.scale) - top - bottom
    return mon.x + left, mon.y + top, w, h
end

local function slot(x, y, w, h)
    return function()
        local mon = hl.get_active_monitor()
        local win = hl.get_active_window()
        if not mon or not win then return end
        local ax, ay, aw, ah = workarea(mon)
        -- hyprland draws the border outside the window, so reserve 2b per
        -- column/row (like set_to_slot in the old rc.lua)
        local b = tonumber(hl.get_config("general.border_size")) or 1
        local sw = math.floor((aw - 6 * b) / 3)
        local sh = math.floor((ah - 4 * b) / 2)
        hl.dispatch(hl.dsp.window.float({ action = "on" }))
        hl.dispatch(hl.dsp.window.resize({ x = sw * w + (w - 1) * 2 * b, y = sh * h + (h - 1) * 2 * b }))
        hl.dispatch(hl.dsp.window.move({ x = ax + b + x * (sw + 2 * b), y = ay + b + y * (sh + 2 * b) }))
    end
end

local mod = "SUPER"

-- described binds are registered so hotkeys.sh can run them via hyprctl eval
hotkey_actions = {}

local function bind(keys, action, opts)
    hl.bind(keys, action, opts)
    if opts and opts.description then
        hotkey_actions[keys:gsub(" ", "")] = action
    end
end

function run_hotkey(keys)
    local action = hotkey_actions[keys]
    if action then
        hl.dispatch(action)
    end
end

-- launcher / session
bind(mod .. " + S", hl.dsp.exec_cmd("~/.config/hypr/hotkeys.sh"), { description = "show help" })
bind(mod .. " + X", hl.dsp.exec_cmd(terminal), { description = "open a terminal" })
bind(mod .. " + R", hl.dsp.exec_cmd('rofi -show run -font "Hack Nerd Font 10" -theme Monokai'), { description = "run prompt" })
bind(mod .. " + W", hl.dsp.exec_cmd('rofi -show window -font "Hack Nerd Font 10" -theme Monokai'), { description = "window prompt" })
bind(mod .. " + N", hl.dsp.exec_cmd("networkmanager_dmenu"), { description = "network menu" })
-- explicit path: the systemd-launched session's PATH lacks ~/.local/bin
bind(mod .. " + B", hl.dsp.exec_cmd("~/.local/bin/bluetoothmenu"), { description = "bluetooth menu" })
bind(mod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/clipmenu.sh"), { description = "clipboard history" })
bind(mod .. " + T", hl.dsp.exec_cmd("~/.config/hypr/thunderbird-toggle.sh"), { description = "toggle mail" })
bind(mod .. " + D", hl.dsp.exec_cmd("~/.config/hypr/powermenu.sh"), { description = "main menu" })
bind(mod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "reload hyprland" })
bind(mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "lock screen" })
bind("Print", hl.dsp.exec_cmd("~/.config/hypr/screenshot.sh"), { description = "screenshot" })

-- client
bind(mod .. " + SHIFT + Q", hl.dsp.window.close(), { description = "close window" })
bind(mod .. " + CTRL + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "toggle fullscreen" })
bind(mod .. " + Tab", function()
    hl.dispatch(hl.dsp.focus({ last = true }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "focus last window" })
bind(mod .. " + left", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "focus next window" })
bind(mod .. " + right", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "focus previous window" })

-- workspaces
bind(mod .. " + CTRL + left", hl.dsp.focus({ workspace = "m-1" }), { description = "previous workspace" })
bind(mod .. " + CTRL + right", hl.dsp.focus({ workspace = "m+1" }), { description = "next workspace" })
for i = 1, 3 do
    bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }), { description = "workspace " .. i })
end

-- manual tile binds, same slots as rc.lua
bind(mod .. " + F", slot(0, 0, 3, 2), { description = "tile: full screen" })
bind(mod .. " + CTRL + 1", slot(0, 0, 2, 2), { description = "tile: x(0 1) y(0 1)" })
bind(mod .. " + CTRL + 2", slot(1, 0, 2, 2), { description = "tile: x(1 2) y(0 1)" })
bind(mod .. " + CTRL + 4", slot(0, 0, 2, 1), { description = "tile: x(0 1) y(0)" })
bind(mod .. " + CTRL + 5", slot(1, 0, 2, 1), { description = "tile: x(1 2) y(0)" })
bind(mod .. " + CTRL + 7", slot(0, 1, 2, 1), { description = "tile: x(0 1) y(1)" })
bind(mod .. " + CTRL + 8", slot(1, 1, 2, 1), { description = "tile: x(1 2) y(1)" })
bind(mod .. " + SHIFT + 1", slot(0, 0, 1, 2), { description = "tile: x(0) y(0 1)" })
bind(mod .. " + SHIFT + 2", slot(1, 0, 1, 2), { description = "tile: x(1) y(0 1)" })
bind(mod .. " + SHIFT + 3", slot(2, 0, 1, 2), { description = "tile: x(2) y(0 1)" })
bind(mod .. " + SHIFT + 4", slot(0, 0, 1, 1), { description = "tile: x(0) y(0)" })
bind(mod .. " + SHIFT + 5", slot(1, 0, 1, 1), { description = "tile: x(1) y(0)" })
bind(mod .. " + SHIFT + 6", slot(2, 0, 1, 1), { description = "tile: x(2) y(0)" })
bind(mod .. " + SHIFT + 7", slot(0, 1, 1, 1), { description = "tile: x(0) y(1)" })
bind(mod .. " + SHIFT + 8", slot(1, 1, 1, 1), { description = "tile: x(1) y(1)" })
bind(mod .. " + SHIFT + 9", slot(2, 1, 1, 1), { description = "tile: x(2) y(1)" })

-- audio / backlight
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- mouse: mod+drag move / resize
bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
