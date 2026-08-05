#! /usr/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

if [[ "$PKG_MANAGER" == "pacman" || "$PKG_MANAGER" == "dnf" ]]; then
    PKG_LIST=(zellij)
    install_pkgs
    enable_fedora_copr
else
    echo "WARNING: Unsupported package manager '$PKG_MANAGER' — skipping packages" >&2
fi

mkdir -p ~/.config/zellij
ln -sf "$PWD"/config.kdl ~/.config/zellij/
