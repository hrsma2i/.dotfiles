#!/bin/bash -eu
TOOL_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

"$DOTFILES_DIR/brew/install_itself.sh"

brew install direnv

TOOL_DIR="$(dirname "$(realpath "$0")")"
TOOL_NAME="$(basename "$TOOL_DIR")"
set -x
ln -sfn "$TOOL_DIR"/zshrc zsh/zshrc.d/"$TOOL_NAME".zshrc
set +x
