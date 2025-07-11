#! /usr/bin/sh
sudo pacman -S --needed zellij
mkdir -p ~/.config/zellij
ln -sf "$PWD"/config.kdl ~/.config/zellij/