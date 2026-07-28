#!/bin/bash
# ensure thunderbird is always running (replaces birdtray's launcher role).
# a fresh start is hidden to the special workspace, like birdtray's
# hidewhenstarted; unhide via Mod+T or the dimmed tasklist entry.
pgrep -x thunderbird >/dev/null && exit 0
thunderbird &

for _ in $(seq 1 50); do
    sleep 0.2
    addr=$(hyprctl clients -j | jq -r '[.[] | select(.class | test("thunderbird"; "i"))][0].address')
    [ -n "$addr" ] && [ "$addr" != "null" ] && break
done
if [ -n "$addr" ] && [ "$addr" != "null" ]; then
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"special:mail\", follow = false, window = \"address:$addr\" }))" >/dev/null
fi
