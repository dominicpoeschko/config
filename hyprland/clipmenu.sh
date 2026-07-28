#!/bin/bash
# clipboard history picker, fed by the wl-paste/cliphist watchers in hyprland.lua
# enter = copy, Alt+d = delete entry, Alt+w = wipe the whole history
while true; do
    sel="$(cliphist list | rofi -dmenu -i -p clipboard -font "Hack Nerd Font 10" -theme Monokai \
        -kb-custom-1 Alt+d -kb-custom-2 Alt+w \
        -mesg "Enter: copy    Alt+d: delete    Alt+w: wipe all")"
    code=$?
    case "$code" in
    0) # nothing selected (empty history): leave the clipboard untouched
        [ -n "$sel" ] || exit 0
        printf '%s' "$sel" | cliphist decode | wl-copy
        exit 0
        ;;
    10) # delete the selected entry, then reopen the menu
        [ -n "$sel" ] && printf '%s' "$sel" | cliphist delete
        ;;
    11)
        cliphist wipe
        exit 0
        ;;
    *) exit 0 ;;
    esac
done
