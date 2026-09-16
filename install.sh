#! /bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

echo "Detected distribution: $DISTRO ($PKG_MANAGER)"

folders=(
    awesome
    clang_format
    contour
    fish
    git
    nvim
    slock
    ssh
    zellij
)

for F in "${folders[@]}"; do
    echo "=== Installing $F ==="
    if [[ -d ${F} ]]; then
        if cd "$F"; then
            if [[ -e install.sh ]]; then
                ./install.sh
            fi
            cd ..
        fi
    fi
done
