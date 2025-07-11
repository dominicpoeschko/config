#! /usr/bin/sh
sudo pacman -S --needed fish fzf lsd most fd inetutils zellij atuin starship
chsh -s /bin/fish
mkdir -p ~/.config/fish
ln -sf "$PWD"/config.fish ~/.config/fish/
ln -sf "$PWD"/config.toml ~/.config/atuin/
ln -sf "$PWD"/starship.toml ~/.config/
