#!/bin/bash -eu

TOOL_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

"$DOTFILES_DIR/brew/install_itself.sh"

brew install uv
