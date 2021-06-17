#!/bin/bash

[[ -e ~/.dotfiles ]] || git clone https://github.com/hrsma2i/.dotfiles.git ~/.dotfiles
pushd ~/.dotfiles || exit

# symlinks
ln -sfn ~/.dotfiles/zshrc ~/.zshrc
mkdir -p ~/.config/git
ln -sfn ~/.dotfiles/gitignore_global ~/.config/git/ignore
ln -sfn ~/.dotfiles/gitconfig ~/.gitconfig
ln -sfn ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -sfn ~/.dotfiles/jupyter ~/.jupyter
ln -sfn ~/.dotfiles/ipython ~/.ipython

./Brewfile.sh
curl https://sdk.cloud.google.com | bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
sudo installer -pkg /tmp/AWSCLIV2.pkg -target / # /usr/local/bin/aws

GLOBAL_PYTHON_VERSION=3.6.5
pyenv install $GLOBAL_PYTHON_VERSION
pyenv global $GLOBAL_PYTHON_VERSION

# shellcheck disable=SC1091
source "$HOME"/.zshrc &&
    pip install -U pip &&
    pip install poetry

# jupyter notebook
# shellcheck disable=SC1091
source "$HOME"/.zshrc &&
    pip install jupyter jupyter-contrib-nbextensions &&
    pip install "nbconvert<=6.0" &&
    python -c 'from notebook.auth import passwd;print(passwd())' >~/.jupyter/key
# Create required directory in case (optional)
mkdir -p "$(jupyter --data-dir)"/nbextensions
# Clone the repository
pushd "$(jupyter --data-dir)"/nbextensions || exit
git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding
# Activate the extension
jupyter nbextension enable vim_binding/vim_binding
popd || exit

popd || exit
