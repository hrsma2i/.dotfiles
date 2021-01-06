#!/bin/bash

[[ -e ~/.dotfiles ]] || git clone https://github.com/hrsma2i/.dotfiles.git ~/.dotfiles
pushd ~/.dotfiles

# symlinks
ln -sfn ~/.dotfiles/zshrc ~/.zshrc
mkdir -p ~/.config/git
ln -sfn ~/.dotfiles/gitignore_global ~/.config/git/ignore
ln -sfn ~/.dotfiles/gitconfig ~/.gitconfig
ln -sfn ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

./Brewfile.sh
curl https://sdk.cloud.google.com | bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
sudo installer -pkg /tmp/AWSCLIV2.pkg -target / # /usr/local/bin/aws

GLOBAL_PYTHON_VERSION=3.6.5
pyenv install $GLOBAL_PYTHON_VERSION
pyenv global $GLOBAL_PYTHON_VERSION

source ~/.zshrc \
&& pip install -U pip \
&& pip install trash-cli \
&& pip install poetry

popd
