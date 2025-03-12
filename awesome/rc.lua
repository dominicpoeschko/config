-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
--require("awful.hotkeys_popup.keys").tmux.add_rules_for_terminal({ rule = { name = "no window ever has a name like this" }})

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.get().font = "Hack Nerd Font 10"
beautiful.get().border_width = beautiful.xresources.apply_dpi(1)

local numTags = 3
tabbed_terminal = "term"
pop_terminal = "popterm"
terminal = "alacritty"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    -- awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu

mymainmenu = awful.menu({ items = {
    { "terminal", tabbed_terminal },
    { "shutdown", function() awful.spawn("systemctl poweroff") end },
    { "restart", function() awful.spawn("systemctl reboot") end },
}
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %a %d.%m.%y %T ", 1)

mymonth_calendar = awful.widget.calendar_popup.month()
mymonth_calendar:attach(mytextclock, "tr", { on_hover = false })

mymemory_graph = wibox.widget {
    max_value = 1,
    step_width = 2,
    background_color = beautiful.get().bg_systray,
    widget = wibox.widget.graph
}


gears.timer.start_new(1,
    function()
        local command = "free | grep Mem: | awk '{ p = $3/$2 }; END { print p}' > /tmp/memusage_wm"
        awful.spawn.easy_async_with_shell(command,
            function()
                awful.spawn.easy_async_with_shell("cat /tmp/memusage_wm", function(out)
                    local memusage = tonumber(out)
                    mymemory_graph:add_value(memusage)
                    if memusage then
                        if memusage > 0.7 then
                            mymemory_graph.color = "#ff0000"
                        else
                            mymemory_graph.color = "#00ff00"
                        end
                    end
                end)
            end)
        return true
    end
)


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local function set_wallpaper(s)
    gears.wallpaper.set("#000000")
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper()

    local names = {};

    for i = 1, numTags do
        table.insert(names, i);
    end

    -- Each screen has its own tag table.
    awful.tag(names, s, awful.layout.layouts[1])

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            wibox.container.mirror(mymemory_graph, { horizontal = true }),
            require("battery-widget") {},
            mytextclock,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

function fix_client_size()
    for s in screen do
        for i,c in ipairs(s.all_clients) do
            local oldw = c.width
            c.width = oldw + 1
            awful.spawn.easy_async("sleep 0.01", function(stdout)
                    c.width = oldw
                end
            )
        end
    end
end

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),

    awful.key({ }, "F12",
        function ()
            local dropdown = function (c)
                return awful.rules.match(c, {name = "popterm"})
            end
            local temp
            for c in awful.client.iterate(dropdown) do
                 temp = c
            end
            if temp and temp.hidden == false then
                temp.hidden = true
            elseif temp then
                temp:move_to_tag(awful.tag.selected())
                temp.hidden = false
                temp.minimized = false
                client.focus = temp
                temp:raise()
            else
                awful.spawn("popterm")
            end
        end,
        { description = "toggle popterm", group = "awesome" }
    ),

    awful.key({ modkey, "Control" }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, "Control" }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),

    awful.key({ modkey, }, "Left",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "Right",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ modkey, }, "d", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "x", function() awful.spawn(tabbed_terminal) end,
        { description = "open a terminal", group = "launcher" }),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),

    awful.key({ modkey, }, "l", function() awful.spawn("xautolock -locknow", false) end,
        { description = "lock screen", group = "awesome" }),

    awful.key({ modkey, }, "k", function() fix_client_size() end,
        { description = "fix client size", group = "awesome" }),

    awful.key({}, "Print", function() awful.spawn("ksnip") end,
        { description = "screenshot", group = "awesome" }),

    -- Prompt
    awful.key({ modkey, }, "r",
        function() awful.spawn("rofi -show run -font \"Hack Nerd Font 10\" -theme Monokai") end,
        { description = "run prompt", group = "launcher" }),

    awful.key({ modkey, }, "w",
        function() awful.spawn("rofi -show window -font \"Hack Nerd Font 10\" -theme Monokai") end,
        { description = "run window prompt", group = "launcher" }),

    awful.key({ modkey, }, "n",
        function() awful.spawn("networkmanager-dmenu") end,
        { description = "run nm prompt", group = "launcher" }),

    awful.key({ modkey, }, "b",
        function() awful.spawn("bluetoothmenu") end,
        { description = "run bluetooth prompt", group = "launcher" }),

    -- Audio volume
    awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false) end)
    ,
    awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false) end)
    ,
    awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false) end),
    -- Backlight
    awful.key({}, "XF86MonBrightnessUp", function() awful.spawn("sudo xbacklight -inc 5", false) end),
    awful.key({}, "XF86MonBrightnessDown", function() awful.spawn("sudo xbacklight -dec 5", false) end)

)

function slot_width(s)
    local sw = s.workarea
    return math.floor((sw.width - 6 * beautiful.border_width) / 3)
end

function slot_height(s)
    local sw = s.workarea
    return math.floor((sw.height - 4 * beautiful.border_width) / 2)
end

function slot_x(s, x)
    local sw = s.workarea
    return slot_width(s) * x + sw.x + (x * beautiful.border_width * 2)
end

function slot_y(s, y)
    local sw = s.workarea
    return slot_height(s) * y + sw.y + (y * beautiful.border_width * 2)
end

function set_to_slot(c, x, y, w, h)
    c.x = slot_x(c.screen, x)
    c.y = slot_y(c.screen, y)
    c.width = slot_width(c.screen) * w + ((w - 1) * beautiful.border_width * 2)
    c.height = slot_height(c.screen) * h + ((h - 1) * beautiful.border_width * 2)
end

clientkeys = gears.table.join(
    awful.key({ modkey, }, "f",
        function(c)
            set_to_slot(c, 0, 0, 3, 2)
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Control" }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "q",
        function(c)
            c:kill()
        end,
        { description = "close", group = "client" }),

    awful.key({ modkey, "Control" }, "1",
        function(c)
            set_to_slot(c, 0, 0, 2, 2)
        end,
        { description = "x(0 1) y(0 1)", group = "manual tile" }),
    awful.key({ modkey, "Control" }, "2",
        function(c)
            set_to_slot(c, 1, 0, 2, 2)
        end,
        { description = "x(1 2) y(0 1)", group = "manual tile" }),
    awful.key({ modkey, "Control" }, "3",
        function(c)
        end,
        false),
    awful.key({ modkey, "Control" }, "4",
        function(c)
            set_to_slot(c, 0, 0, 2, 1)
        end,
        { description = "x(0 1) y(0)", group = "manual tile" }),
    awful.key({ modkey, "Control" }, "5",
        function(c)
            set_to_slot(c, 1, 0, 2, 1)
        end,
        { description = "x(1 2) y(0)", group = "manual tile" }),
    awful.key({ modkey, "Control" }, "6",
        function(c)
        end,
        false),
    awful.key({ modkey, "Control" }, "7",
        function(c)
            set_to_slot(c, 0, 1, 2, 1)
        end,
        { description = "x(0 1) y(1)", group = "manual tile" }),
    awful.key({ modkey, "Control" }, "8",
        function(c)
            set_to_slot(c, 1, 1, 2, 1)
        end,
        { description = "x(1 2) y(1)", group = "manual tile" }),
    awful.key({ modkey, "Control" }, "9",
        function(c)
        end,
        false),
    awful.key({ modkey, "Shift" }, "1",
        function(c)
            set_to_slot(c, 0, 0, 1, 2)
        end,
        { description = "x(0) y(0 1)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "2",
        function(c)
            set_to_slot(c, 1, 0, 1, 2)
        end,
        { description = "x(1) y(0 1)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "3",
        function(c)
            set_to_slot(c, 2, 0, 1, 2)
        end,
        { description = "x(2) y(0 1)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "4",
        function(c)
            set_to_slot(c, 0, 0, 1, 1)
        end,
        { description = "x(0) y(0)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "5",
        function(c)
            set_to_slot(c, 1, 0, 1, 1)
        end,
        { description = "x(1) y(0)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "6",
        function(c)
            set_to_slot(c, 2, 0, 1, 1)
        end,
        { description = "x(2) y(0)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "7",
        function(c)
            set_to_slot(c, 0, 1, 1, 1)
        end,
        { description = "x(0) y(1)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "8",
        function(c)
            set_to_slot(c, 1, 1, 1, 1)
        end,
        { description = "x(1) y(1)", group = "manual tile" }),
    awful.key({ modkey, "Shift" }, "9",
        function(c)
            set_to_slot(c, 2, 1, 1, 1)
        end,
        { description = "x(2) y(1)", group = "manual tile" })
)

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = {},
        properties = { border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- popterm
    {
        rule_any = {
            name = { "popterm" }
        },
        properties = { placement = awful.placement.top_left,
            width = slot_width(screen[1]) * 2 + beautiful.border_width * 2,
            height = slot_height(screen[1]) }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- My stuff {{{

--key repeate rate
os.execute("xset r rate 200 30")
--disable screensaver
os.execute("xset dpms 0 0 0")
os.execute("xset -dpms")
os.execute("xset s  0 0")
os.execute("xset s off")
--autostart

awful.spawn.with_shell("numlockx &");

--local result = os.execute("pgrep -x keepassxc")
--if result ~= true and result ~= 0 then
--    awful.spawn.with_shell("echo | keepassxc --keyfile /home/dominic/repos/000_config/key --pw-stdin /home/dominic/owncloud/Passwords.kdbx");
--end

local result = os.execute("pgrep -x pasystray")
if result ~= true and result ~= 0 then
    awful.spawn("pasystray", false);
end

local result = os.execute("pgrep -x telegram-deskto")
if result ~= true and result ~= 0 then
    awful.spawn("telegram-desktop -startintray", false);
end

--local result = os.execute("pgrep -x owncloud")
--if result ~= true and result ~= 0 then
--    awful.spawn.with_shell("sleep 1 && owncloud",false);
--end

local function getHostname()
    local f = io.popen("/bin/hostname")
    local hostname = f:read("*a") or ""
    f:close()
    hostname = string.gsub(hostname, "\n$", "")
    return hostname
end

local hostname = getHostname()

local result = os.execute("pgrep -x birdtray")
if result ~= true and result ~= 0 then
    awful.spawn("birdtray", false);
end

if hostname == "dominic-t580" or hostname == "dominic-laptop" or hostname == "dominic-workstation" or hostname == "dp-probook" then
    awful.spawn.with_shell("xautolock -notify 10 -notifier \"notify-send -u critical -t 10000 \\\"Lock in 10 sec\\\"\" -time 15 -locker \"xset dpms force off & slock && xset dpms 0 0 0 && xset -dpms\"  &")
end

-- }}}
