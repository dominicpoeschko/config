#! /usr/bin/sh
sudo pacman -S --needed thunderbird awesome rofi pasystray numlockx xlockmore thunderbird pavucontrol paprefs keepassxc xautolock gnome-themes-extra qt5ct acpid acpilight
trizen -S --needed birdtray systemd-numlockontty ksnip networkmanager-dmenu-git
#systemctl --user enable pulseaudio.socket
sudo systemctl enable numLockOnTty.service
sudo systemctl enable acpid.service
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

ln -sf "$PWD"/birdtray-config.json ~/.config
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo ln -sf "$PWD"/override.conf /etc/systemd/system/getty@tty1.service.d
sudo cp "$PWD"/backlight_sudo /etc/sudoers.d
