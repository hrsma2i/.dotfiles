#!/bin/bash

DOTFILES="$HOME/.dotfiles"

[[ -e "$DOTFILES" ]] || git clone https://github.com/hrsma2i/.dotfiles.git "$DOTFILES"
pushd "$DOTFILES" || exit

# brew/install_itself.sh
zsh/install.sh
mise/install.sh
git/install.sh

# symlinks
# ln -sfn ~/.dotfiles/jupyter ~/.jupyter
# ln -sfn ~/.dotfiles/ipython ~/.ipython
ln -sfn ~/.dotfiles/starship.toml ~/.config/starship.toml

# ./Brewfile.sh

# AWS
# curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
# sudo installer -pkg /tmp/AWSCLIV2.pkg -target / # /usr/local/bin/aws

# Node.js
# ./setup_nodejs.sh

popd || exit
