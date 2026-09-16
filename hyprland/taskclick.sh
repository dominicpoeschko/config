#!/bin/bash
# waybar tasklist click ($1 = window address, $2 = mouse button):
#   hidden window                  -> unhide onto the current workspace + raise
#   left click, anything else      -> focus and raise
#   left click on the entry this
#     bar raised last, still focused -> hide (special workspace, dimmed in the bar)
#   right click                    -> hide unconditionally
#
# the hide toggle keys off the *previous bar click*, not off "is it focused?"
# like awesome did. hyprland's follow_mouse focuses every window the pointer
# crosses on its way up to the bar, so the plain focused-check turned clicks
# meant to raise a buried window into a hide.
addr="$1"
button="${2:-1}"
[ -n "$addr" ] || exit 0

dir="${XDG_RUNTIME_DIR:-/tmp}/taskclick"
mkdir -p "$dir"

# debounce: a double click delivers two GDK_BUTTON_PRESS events, which would
# turn a raise into a raise+hide
now=$(date +%s%N)
last=$(cat "$dir/click-$addr" 2>/dev/null || echo 0)
echo "$now" >"$dir/click-$addr"
[ $((now - last)) -lt 400000000 ] && exit 0

# one snapshot: two hyprctl clients calls can disagree about where the window is
client=$(hyprctl clients -j | jq -c --arg a "$addr" '.[] | select(.address == $a)')
[ -n "$client" ] || exit 0
ws=$(jq -r '.workspace.name' <<<"$client")
class=$(jq -r '.class' <<<"$client")

raise() {
    # one eval: focus and z-order in a single dispatch batch, both pinned to the
    # address (see raise_window in hyprland.lua)
    hyprctl eval "raise_window('$addr')" >/dev/null
    echo "$addr" >"$dir/raised"
}

hide() {
    # thunderbird hides to its own special workspace, which waybar ignores
    # completely (no dimmed entry); everything else stays visible in the bar.
    # follow = false sends it away silently instead of dragging the special
    # workspace onto the screen
    local target="special:hidden"
    case "$class" in *hunderbird*) target="special:mail" ;; esac
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$target\", follow = false, window = \"address:$addr\" }))" >/dev/null
    rm -f "$dir/raised"
}

if [[ "$ws" == special:* ]]; then
    cur=$(hyprctl activeworkspace -j | jq .id)
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = $cur, follow = false, window = \"address:$addr\" }))" >/dev/null
    raise
elif [ "$button" = 3 ]; then
    hide
elif [ "$(hyprctl activewindow -j | jq -r .address)" = "$addr" ] &&
    [ "$(cat "$dir/raised" 2>/dev/null)" = "$addr" ]; then
    hide
else
    raise
fi
