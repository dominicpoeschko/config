#! /usr/bin/sh
sudo pacman -S --needed hyprland waybar hyprlock hypridle mako xdg-desktop-portal-hyprland qt5-wayland qt6-wayland brightnessctl jq libnotify rofi pavucontrol wl-clipboard cliphist grim slurp satty xdotool meson ninja

# waybar with local hyprland fixes, installs to ~/.local/bin/waybar
"$PWD"/build-waybar.sh

mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/mako

ln -sf "$PWD"/hyprland.lua ~/.config/hypr/hyprland.lua
ln -sf "$PWD"/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -sf "$PWD"/hypridle.conf ~/.config/hypr/hypridle.conf
ln -sf "$PWD"/powermenu.sh ~/.config/hypr/powermenu.sh
ln -sf "$PWD"/clipmenu.sh ~/.config/hypr/clipmenu.sh
ln -sf "$PWD"/locklabel.sh ~/.config/hypr/locklabel.sh
ln -sf "$PWD"/screenshot.sh ~/.config/hypr/screenshot.sh
ln -sf "$PWD"/thunderbird-toggle.sh ~/.config/hypr/thunderbird-toggle.sh
ln -sf "$PWD"/mail-keepalive.sh ~/.config/hypr/mail-keepalive.sh
ln -sf "$PWD"/taskclick.sh ~/.config/hypr/taskclick.sh
ln -sf "$PWD"/hotkeys.sh ~/.config/hypr/hotkeys.sh
mkdir -p ~/.local/bin
ln -sf "$PWD"/../awesome/bluetoothmenu ~/.local/bin/bluetoothmenu
ln -sf "$PWD"/waybar-config.jsonc ~/.config/waybar/config.jsonc
ln -sf "$PWD"/waybar-style.css ~/.config/waybar/style.css
ln -sf "$PWD"/mako-config ~/.config/mako/config

# tty2 is a normal password login (systemd default), fish then starts Hyprland there
sudo rm -rf /etc/systemd/system/getty@tty2.service.d
sudo systemctl daemon-reload
