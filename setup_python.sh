#!/bin/bash -eu

pipx install poetry
git clone https://github.com/pyenv/pyenv-update.git "$(pyenv root)"/plugins/pyenv-update
GLOBAL_PYTHON_VERSION=3.11.4
pyenv install $GLOBAL_PYTHON_VERSION
pyenv global $GLOBAL_PYTHON_VERSION

# shellcheck disable=SC1091
source "$HOME"/.zshrc &&
    pip install -U pip

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
