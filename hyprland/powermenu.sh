#!/bin/bash
# replacement for the awesome root menu: terminal / shutdown / reboot
case "$(printf 'terminal\nshutdown\nreboot' | rofi -dmenu -p power -font 'Hack Nerd Font 10' -theme Monokai)" in
terminal) kitty & ;;
shutdown) systemctl poweroff ;;
reboot) systemctl reboot ;;
esac
