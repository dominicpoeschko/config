#!/bin/bash
# show/hide thunderbird (native wayland): reuses the tasklist click semantics
# (focused -> hide, hidden -> unhide, otherwise -> focus)
addr=$(hyprctl clients -j | jq -r '[.[] | select(.class | test("thunderbird"; "i"))][0].address')
if [ -z "$addr" ] || [ "$addr" = "null" ]; then
    exec thunderbird
fi
exec ~/.config/hypr/taskclick.sh "$addr"
