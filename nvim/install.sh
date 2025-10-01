#!/bin/sh
yay -S --needed cmake-language-server ruby-neovim
sudo pacman -S --needed python-pdm neovim nodejs yarn npm python-pip ripgrep fzf python-pynvim ruby cpanminus x11-ssh-askpass lua-language-server vscode-json-languageserver bash-language-server sqlite

cpanm --sudo -n Neovim::Ext
sudo npm install -g neovim
sudo yarn global add neovim

rm -rf ~/.vimrc
rm -rf ~/.vim
rm -rf ~/.config/nvim

rm -rf ~/.local/share/nvim

ln -sf "$PWD"/nvim ~/.config
