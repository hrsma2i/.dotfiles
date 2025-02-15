#!/bin/bash -eu
DOTFILES_DIR="$HOME/.dotfiles"
pushd "$DOTFILES_DIR" || exit 1

mise/install.sh

NODE_VERSION=20

mise install node@$NODE_VERSION
mise use -g node@$NODE_VERSION

popd
