#! /usr/bin/sh
sudo pacman -S --needed xdotool tmux
sudo ln -sf "$PWD"/term /usr/local/bin/
sudo ln -sf "$PWD"/popterm /usr/local/bin/
sudo ln -sf "$PWD"/closing-tmux /usr/local/bin/
