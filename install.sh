#!/bin/bash

DOTFILES="$HOME/.dotfiles"

[[ -e "$DOTFILES" ]] || git clone https://github.com/hrsma2i/.dotfiles.git "$DOTFILES"
pushd "$DOTFILES" || exit

zsh/install.sh

# symlinks
# mkdir -p ~/.config/git
# ln -sfn ~/.dotfiles/gitignore_global ~/.config/git/ignore
# ln -sfn ~/.dotfiles/gitconfig ~/.gitconfig
# ln -sfn ~/.dotfiles/jupyter ~/.jupyter
# ln -sfn ~/.dotfiles/ipython ~/.ipython
# ln -sfn ~/.dotfiles/starship.toml ~/.config/starship.toml

# ./Brewfile.sh

# GCP
# curl https://sdk.cloud.google.com | bash

# AWS
# curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
# sudo installer -pkg /tmp/AWSCLIV2.pkg -target / # /usr/local/bin/aws

# Python
# ./setup_python.sh

# Node.js
# ./setup_nodejs.sh

popd || exit
