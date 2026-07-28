#!/bin/bash
# waybar tasklist click ($1 = window address), awesome-tasklist semantics:
#   hidden window        -> unhide onto the current workspace and focus
#   focused window       -> hide (special workspace, stays in the bar dimmed)
#   other visible window -> focus and raise
addr="$1"
# debounce: waybar can deliver the same click twice, which would turn a
# focus into a focus+hide
now=$(date +%s%N)
last=$(cat "/tmp/.taskclick-$addr" 2>/dev/null || echo 0)
echo "$now" >"/tmp/.taskclick-$addr"
[ $((now - last)) -lt 400000000 ] && exit 0

ws=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$addr\") | .workspace.name")
[ -n "$ws" ] || exit 0

# thunderbird hides to its own special workspace which waybar ignores
# completely (no dimmed entry); everything else stays visible in the bar
target="special:hidden"
case "$(hyprctl clients -j | jq -r ".[] | select(.address == \"$addr\") | .class")" in
*hunderbird*) target="special:mail" ;;
esac

if [[ "$ws" == special:* ]]; then
    cur=$(hyprctl activeworkspace -j | jq .id)
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = $cur, follow = false, window = \"address:$addr\" }))" >/dev/null
    hyprctl eval "hl.dispatch(hl.dsp.focus({ window = \"address:$addr\" }))" >/dev/null
elif [ "$(hyprctl activewindow -j | jq -r .address)" = "$addr" ]; then
    # follow = false: send it away silently instead of dragging the special
    # workspace onto the screen
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$target\", follow = false, window = \"address:$addr\" }))" >/dev/null
else
    hyprctl eval "hl.dispatch(hl.dsp.focus({ window = \"address:$addr\" }))" >/dev/null
    hyprctl eval "hl.dispatch(hl.dsp.window.bring_to_top())" >/dev/null
fi
