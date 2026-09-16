#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

if [[ "$PKG_MANAGER" == "pacman" || "$PKG_MANAGER" == "dnf" ]]; then
    PKG_LIST=(git-delta)
    install_pkgs
    enable_fedora_copr
else
    echo "WARNING: Unsupported package manager '$PKG_MANAGER' — skipping packages" >&2
fi

ln -sf "$PWD"/gitconfig ~/.gitconfig
