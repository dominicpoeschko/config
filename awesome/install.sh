#! /usr/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

if [[ "$PKG_MANAGER" == "pacman" ]]; then
    PKG_LIST=(thunderbird awesome rofi pasystray numlockx xlockmore pavucontrol paprefs keepassxc xautolock gnome-themes-extra qt5ct acpid acpilight)
    install_pkgs
    install_aur_pkg birdtray
    install_aur_pkg systemd-numlockontty
    install_aur_pkg ksnip
    install_aur_pkg networkmanager-dmenu-git
elif [[ "$PKG_MANAGER" == "dnf" ]]; then
    PKG_LIST=(thunderbird awesome rofi pavucontrol paprefs keepassxc xautolock adwaita-legacy-gtk-theme qt5ct acpid ksnip pasystray brightnessctl)
    install_pkgs
    enable_fedora_copr || true
    if ! dnf repolist copr 2>/dev/null | grep -q 'tofik/sway-tools'; then
        echo "Enabling COPR repo: tofik/sway-tools (for networkmanager-dmenu)" >&2
        dnf copr enable -y tofik/sway-tools 2>/dev/null
        if [[ $? -ne 0 ]]; then
            echo "WARNING: Could not enable tofik/sway-tools COPR (may require manual setup)" >&2
        fi
    fi
    PKG_LIST=(networkmanager-dmenu)
    install_pkgs
    echo "NOTE: AUR-only packages skipped on Fedora: systemd-numlockontty, birdtray" >&2
fi

#systemctl --user enable pulseaudio.socket
if systemctl list-unit-files numLockOnTty.service &>/dev/null; then
    sudo systemctl enable numLockOnTty.service
else
    echo "NOTE: numLockOnTty.service does not exist — skipping" >&2
fi
if systemctl list-unit-files acpid.service &>/dev/null; then
    sudo systemctl enable acpid.service
else
    echo "NOTE: acpid.service does not exist — skipping" >&2
fi
mkdir -p ~/.config/awesome
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/qt5ct

ln -sf "$PWD"/rc.lua ~/.config/awesome
ln -sf "$PWD"/battery-widget.lua ~/.config/awesome
ln -sf "$PWD"/xinitrc ~/.xinitrc
ln -sf "$PWD"/gtkrc-2.0 ~/.gtkrc-2.0
ln -sf "$PWD"/settings.ini ~/.config/gtk-3.0
ln -sf "$PWD"/qt5ct.conf ~/.config/qt5ct/qt5ct.conf
ln -sf "$PWD"/mimeapps.list ~/.config
ln -sf "$PWD"/networkmanager-dmenu ~/.config
ln -sf "$PWD"/mimeapps.list ~/.local/share/applications/mimeapps.list

# bluetoothmenu without needing sudo: ~/.local/bin is in PATH
mkdir -p ~/.local/bin
ln -sf "$PWD"/bluetoothmenu ~/.local/bin/bluetoothmenu
sudo mkdir -p /etc/X11/xorg.conf.d
sudo ln -sf "$PWD"/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo ln -sf "$PWD"/override.conf /etc/systemd/system/getty@tty1.service.d
sudo cp "$PWD"/backlight_sudo /etc/sudoers.d
