#!/bin/bash -eu

TOOL_DIR=$(cd "$(dirname "$0")" && pwd)
TOOL_NAME="$(basename "$TOOL_DIR")"
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

set -x
ln -sfn "$TOOL_DIR/zshrc" "$DOTFILES_DIR/zsh/zshrc.d/$TOOL_NAME.zshrc"
set +x
