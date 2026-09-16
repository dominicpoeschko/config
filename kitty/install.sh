#!/usr/bin/env bash
#sudo pacman -S --needed kitty
rm -rf ~/.config/kitty
ln -sf "$PWD"/kitty ~/.config/kitty
