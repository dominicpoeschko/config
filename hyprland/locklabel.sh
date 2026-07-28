#!/bin/bash
# hyprlock label helper: $1 = time|date, $2 = failed attempts.
# text turns red after a failed unlock, like slock's failure color.
if [ "${2:-0}" -gt 0 ]; then
    color="#cc2222"
elif [ "$1" = "time" ]; then
    color="#ffffff"
else
    color="#aaaaaa"
fi

case "$1" in
time) text=$(date +%H:%M:%S) ;;
date) text=$(date "+%a %d.%m.%y") ;;
esac

printf '<span foreground="%s">%s</span>' "$color" "$text"
