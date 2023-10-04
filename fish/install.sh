#! /usr/bin/sh
sudo pacman -S --needed fish fzf lsd most fd inetutils tmux atuin
chsh -s /bin/fish
mkdir -p ~/.config/fish
ln -sf "$PWD"/config.fish ~/.config/fish/
ln -sf "$PWD"/config.toml ~/.config/atuin/
