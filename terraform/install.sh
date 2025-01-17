#!/bin/bash -eu
DOTFILES_DIR="$HOME/.dotfiles"
pushd "$DOTFILES_DIR" || exit 1

mise/install.sh

mise install terraform
mise use -g terraform

popd
