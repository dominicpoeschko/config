#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

if [[ "$PKG_MANAGER" == "pacman" || "$PKG_MANAGER" == "dnf" ]]; then
    PKG_LIST=(fish fzf lsd most fd inetutils zellij atuin starship)
    install_pkgs
    enable_fedora_copr
else
    echo "WARNING: Unsupported package manager '$PKG_MANAGER' — skipping packages" >&2
fi

chsh -s /bin/fish
mkdir -p ~/.config/fish ~/.config/atuin
ln -sf "$PWD"/config.fish ~/.config/fish/
ln -sf "$PWD"/config.toml ~/.config/atuin/
ln -sf "$PWD"/starship.toml ~/.config/
