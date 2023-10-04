#! /bin/bash

folders=(
    slock
    clang_format
    fish
    tmux
    alacritty
    awesome
    git
    term
    ssh
    nvim
)

for F in "${folders[@]}"
do
    echo Installing "$F"
    if [[ -d ${F} ]]; then
        if cd "$F"; then
            if [[ -e install.sh ]]; then
                ./install.sh
            fi
            cd ..
        fi
    fi
done

