#!/usr/bin/env bash
# lib.sh — distro detection and helper functions
# Source from any install.sh:  source "$(dirname "$0")/lib.sh"
# Sets PKG_MANAGER, DISTRO, AUR_HELPER and defines install_pkgs, install_aur_pkg.

# Avoid re-detection if already set
if [[ -z "${PKG_MANAGER:-}" ]]; then

    if command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        DISTRO="arch"
        AUR_HELPER="yay"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        DISTRO="fedora"
    else
        echo "ERROR: No supported package manager found (pacman or dnf required)." >&2
        exit 1
    fi

    export PKG_MANAGER DISTRO AUR_HELPER
fi

# Enable required COPR repos for Fedora.
# Call once before install_pkgs if your packages need them.
enable_fedora_copr() {
    if [[ "$DISTRO" != "fedora" ]]; then return 0; fi

    local repo
    for repo in hyprland/hyprland aerfanr/birdtray; do
        if ! dnf repolist copr 2>/dev/null | grep -q "$repo"; then
            echo "Enabling COPR repo: $repo"
            dnf copr enable -y "$repo"
        fi
    done
}

# Install a list of packages.
# Usage: PKG_LIST=(pkg1 pkg2 pkg3); install_pkgs
install_pkgs() {
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        sudo pacman -S --needed "${PKG_LIST[@]}"
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y "${PKG_LIST[@]}"
    fi
}

# Install a single AUR package (Arch only).
# Usage: install_aur_pkg <pkgname>
install_aur_pkg() {
    local pkg="$1"
    if [[ "$DISTRO" == "arch" ]]; then
        if [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -S --needed "$pkg"
        else
            echo "WARNING: No AUR helper found. Install yay to get: $pkg" >&2
        fi
    else
        echo "WARNING: Skipping AUR package '$pkg' (not on Arch)" >&2
    fi
}
