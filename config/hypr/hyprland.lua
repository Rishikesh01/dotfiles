-- Hyprland config (Lua) -- migrated from hyprland.conf
-- Docs: https://wiki.hypr.land/Configuring/Start/
-- Stub/API reference: /usr/share/hypr/stubs/hl.meta.lua
-- Upstream example:   /usr/share/hypr/hyprland.lua

---@module 'hl'

-- Monitor #############################################

hl.monitor({ output = "DP-3",  mode = "highrr", position = "0x0",    scale = 1 })
hl.monitor({ output = "eDP-2", mode = "highrr", position = "2560x0", scale = 1 })

-- Env #################################################

hl.env("LC_NUMERIC", "C")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Autostart ###########################################

hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("swaybg -i ~/.config/hypr/wallpapers/wallpaper2.jpg")
    hl.exec_cmd("dunst")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("~/.config/hypr/desktop-portals.sh")
    hl.exec_cmd("~/.config/hypr/copydots.sh")
    -- copyq has autostart=false in copyq.conf and no XDG/systemd autostart entry,
    -- so it has to be started here. --start-server is a no-op if already running.
    hl.exec_cmd("copyq --start-server")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("echo us > /tmp/kb_layout")
    hl.exec_cmd("wlsunset -S 9:00 -s 6:00 -t 4500")
    hl.exec_cmd("waybar")

    -- Mongodb Daemon
    -- hl.exec_cmd("mongod --dbpath ~/database")
end)

-- Input #############################################

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.
    },
})

-- General / Misc / Decoration ########################

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = "0xffffce8a",
            inactive_border = "0xff444444",
        },

        layout        = "dwindle",
        allow_tearing = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        enable_swallow          = true,
    },

    decoration = {
        rounding = 8,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            offset       = { 0, 0 },
            range        = 0,
            render_power = 2,
            color        = "0x66000000",
        },

        blur = {
            enabled           = true,
            size              = 3,
            passes            = 3,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true, -- you probably want this
    },

    group = {
        groupbar = {
            font_size = 14,
        },
    },
})

-- Animations #########################################

hl.curve("overshot",  { type = "bezier", points = { { 0.05, 0.9 }, { 0.1,  1.05  } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0   }, { 0.66, -0.56 } } })
hl.curve("smoothIn",  { type = "bezier", points = { { 0.25, 1   }, { 0.5,  1     } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "border",      enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 3, bezier = "smoothIn" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3, bezier = "default" })

-- Window rules #######################################
-- NOTE: rules are evaluated top to bottom; order matters.

-- Polkit + dialogs
-- Matchers are unanchored regexes, so "Confirm" also covers "Confirm to replace
-- files" (which had its own redundant rule in hyprland.conf).
hl.window_rule({ match = { class = "org.polkit-gnome-authentication-agent-1" }, float = true })
hl.window_rule({ match = { title = "File Operation Progress" },                float = true })
hl.window_rule({ match = { title = "Confirm" },                                float = true })
hl.window_rule({ match = { title = "dialog" },                                 float = true })

-- Appearance and launchers
hl.window_rule({ match = { class = "Lxappearance" },                 float = true })
hl.window_rule({ match = { class = "Rofi" },                         float = true })
hl.window_rule({ match = { class = "viewnior" },                     float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" },   float = true })

-- wlogout
hl.window_rule({ match = { class = "wlogout" }, fullscreen = true })

-- Workspace rules ####################################

for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-3" })
end

-- Submaps ############################################

-- Remina: SUPER+Delete grabs input, SUPER+SHIFT+Delete releases it.
hl.bind("SUPER + Delete", hl.dsp.submap("grabOn"))
hl.define_submap("grabOn", function()
    hl.bind("SUPER + SHIFT + Delete", hl.dsp.submap("reset"))
end)

-- Screenshots ########################################

hl.bind("Print",
    hl.dsp.exec_cmd("grim $(xdg-user-dir PICTURES)/$(date +'%s.png') && ~/.config/hypr/scripts/screenshot_notify"))
hl.bind("SUPER + S",
    hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +\"Screenshot_%Y-%m-%d_%H-%M-%S.png\") && ~/.config/hypr/scripts/screenshot_notify"))

-- Launchers ##########################################

hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind("SUPER + Return",    hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + N",         hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + M",         hl.dsp.exec_cmd("code"))
hl.bind("SUPER + D",         hl.dsp.exec_cmd("sh ~/.config/rofi/launchers/type-7/launcher.sh"))
hl.bind("SUPER + E",         hl.dsp.exec_cmd("rofi -modi emoji -show emoji -theme ~/.config/waybar/scripts/rofi/emoji.rasi"))
hl.bind("SUPER + C",         hl.dsp.exec_cmd("copyq toggle"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("sh ~/.config/rofi/powermenu/type-7/powermenu.sh"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("sh ~/.config/waybar/scripts/power-profiles"))

-- Lock. Lives on CTRL+ALT+L so SUPER+SHIFT+L stays free for movewindow-right.
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd("hyprlock -c $HOME/.config/hypr/hyprlock.conf"))

-- Volume and brightness ##############################

-- Optional: add `, { locked = true, repeating = true }` to these to make them
-- hold-to-repeat and work on the lock screen (that's what upstream ships).
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pamixer -i 5 && ~/.config/hypr/scripts/volume_notify"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pamixer -d 5 && ~/.config/hypr/scripts/volume_notify"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d 'intel_backlight' set 5%+ && ~/.config/hypr/scripts/brightness_notify"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d 'intel_backlight' set 5%- && ~/.config/hypr/scripts/brightness_notify"))

-- Window management ##################################

hl.bind("SUPER + Q",             hl.dsp.window.close())
hl.bind("SUPER + F",             hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.float())
hl.bind("SUPER + P",             hl.dsp.window.pseudo()) -- dwindle
-- hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())
-- hl.bind("SUPER + S", hl.dsp.layout("togglesplit")) -- dwindle

-- Focus ##############################################

hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))

-- Arrow keys (left/right were swapped in hyprland.conf; corrected here)
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- Move ###############################################

hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Resize #############################################

hl.bind("SUPER + ALT + h", hl.dsp.window.resize({ x = -50, y = 0,   relative = true }))
hl.bind("SUPER + ALT + l", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }))
hl.bind("SUPER + ALT + k", hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
hl.bind("SUPER + ALT + j", hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }))

hl.bind("SUPER + CTRL + up",   hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind("SUPER + CTRL + down", hl.dsp.window.resize({ x = 0, y = 20,  relative = true }))

-- Monitors ###########################################

hl.bind("SUPER + CTRL + left",  hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind("SUPER + CTRL + right", hl.dsp.workspace.move({ monitor = "+1" }))

-- Tabbed (groups) ####################################

hl.bind("SUPER + g",   hl.dsp.group.toggle())
hl.bind("SUPER + tab", hl.dsp.group.next())

-- Special workspace ##################################

hl.bind("SUPER + x",         hl.dsp.workspace.toggle_special())
hl.bind("SUPER + SHIFT + x", hl.dsp.window.move({ workspace = "special" }))

-- Switch / move to workspace #########################

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + CTRL + h", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + l", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + ALT + up",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + ALT + down", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse ##############################################

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
