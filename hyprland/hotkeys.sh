#!/bin/bash
# hotkey help popup, like awesome's Mod+s
# modmask bits: SHIFT=1 CTRL=4 ALT=8 SUPER=64
hyprctl binds -j | jq -r '
    .[] | select(.has_description) |
    ( [ (if .modmask % 128 >= 64 then "SUPER" else empty end),
        (if .modmask % 8   >= 4  then "CTRL"  else empty end),
        (if .modmask % 16  >= 8  then "ALT"   else empty end),
        (if .modmask % 2   >= 1  then "SHIFT" else empty end),
        .key
      ] | join("+") ) + "\t" + .description' |
    column -t -s "$(printf '\t')" |
    rofi -dmenu -i -p hotkeys -font "Hack Nerd Font 10" -theme Monokai |
    {
        read -r sel || exit 0
        # first column is the key combo; run its registered action (see hyprland.lua)
        hyprctl eval "run_hotkey('${sel%% *}')" >/dev/null
    }
