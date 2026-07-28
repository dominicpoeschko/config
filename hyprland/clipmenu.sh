#!/bin/bash
# clipboard history picker, fed by the wl-paste/cliphist watchers in hyprland.lua
sel="$(cliphist list | rofi -dmenu -i -p clipboard -font "Hack Nerd Font 10" -theme Monokai)"
# nothing selected (Esc / empty history): leave the clipboard untouched
[ -n "$sel" ] || exit 0
printf '%s' "$sel" | cliphist decode | wl-copy
