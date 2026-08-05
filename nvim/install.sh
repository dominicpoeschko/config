#! /usr/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

if [[ "$PKG_MANAGER" == "pacman" ]]; then
    install_aur_pkg cmake-language-server
    install_aur_pkg ruby-neovim
    PKG_LIST=(python-pdm neovim nodejs yarn npm python-pip ripgrep fzf python-pynvim ruby cpanminus x11-ssh-askpass lua-language-server vscode-json-languageserver bash-language-server sqlite yaml-language-server)
    install_pkgs

    cpanm --sudo -n Neovim::Ext
    sudo npm install -g neovim
    sudo yarn global add neovim
elif [[ "$PKG_MANAGER" == "dnf" ]]; then
    PKG_LIST=(neovim nodejs yarn npm python3-pip ripgrep fzf ruby cpanminus x11-ssh-askpass sqlite)
    install_pkgs
    echo "NOTE: AUR-only packages skipped on Fedora: ruby-neovim, python3-pynvim" >&2
    # Install language servers that aren't in Fedora repos
    sudo pip3 install cmake-language-server
    sudo npm install -g lua-language-server 2>/dev/null || echo "NOTE: lua-language-server not available on npm — install manually" >&2
    sudo npm install -g vscode-json-languageserver
    sudo npm install -g bash-language-server
    sudo npm install -g yaml-language-server
    echo "NOTE: Language servers installed via npm/pip on Fedora" >&2
else
    echo "WARNING: Unsupported package manager '$PKG_MANAGER' — skipping packages" >&2
fi

rm -rf ~/.vimrc
rm -rf ~/.vim
rm -rf ~/.config/nvim

rm -rf ~/.local/share/nvim

ln -sf "$PWD"/nvim ~/.config
