#! /usr/bin/sh
sudo pacman -S --needed alacritty ttf-hack-nerd ttf-hack
mkdir -p ~/.config/alacritty
ln -sf "$PWD"/alacritty.toml ~/.config/alacritty/
