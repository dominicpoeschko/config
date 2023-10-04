#! /usr/bin/sh
rm -rf slock
git clone -q https://git.suckless.org/slock

if [[ -d slock ]]; then
    cd slock
    git checkout -q 35633d45672d14bd798c478c45d1a17064701aa9
    git apply ../slock.diff
    make -s
    sudo make -s install
    cd ..
fi
rm -rf slock
