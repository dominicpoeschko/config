#!/bin/bash
# builds waybar 0.15.0 with local hyprland fixes (see waybar-hyprland-fixes.patch:
# stable merged tasklist with dimmed-in-place hidden windows, lua-dispatch
# workspace clicks, no active-highlight flicker) into ~/.local/bin/waybar.
# restart_waybar in hyprland.lua prefers that binary over the repo package;
# delete ~/.local/bin/waybar to fall back once upstream has caught up.
set -e
patch_dir=$(dirname "$(realpath "$0")")
src=~/.local/src/waybar

if [ ! -d "$src" ]; then
    git clone --depth 1 --branch 0.15.0 https://github.com/Alexays/Waybar.git "$src"
fi
cd "$src"
git fetch --depth 1 origin tag 0.15.0
git checkout -f 0.15.0 2> /dev/null
git apply "$patch_dir"/waybar-hyprland-fixes.patch

[ -d build ] || meson setup build --prefix ~/.local -Dman-pages=disabled -Dcava=disabled
ninja -C build waybar
mkdir -p ~/.local/bin
# unlink first: cp onto the binary of a running waybar fails with "text file busy"
rm -f ~/.local/bin/waybar
cp build/waybar ~/.local/bin/waybar
echo "patched waybar installed to ~/.local/bin/waybar"
