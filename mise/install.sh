#!/bin/bash -eu
# https://mise.jdx.dev/getting-started.html
DOTFILES_DIR="$HOME/.dotfiles"
pushd "$DOTFILES_DIR" || exit 1

brew/install_itself.sh

brew install mise

TOOL_DIR="$(dirname "$(realpath "$0")")"
TOOL_NAME="$(basename "$TOOL_DIR")"
set -x
ln -sfn "$TOOL_DIR"/zshrc zsh/zshrc.d/"$TOOL_NAME".zshrc
set +x

popd
