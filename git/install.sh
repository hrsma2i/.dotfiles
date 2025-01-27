#!/bin/bash -eu

TOOL_DIR=$(cd "$(dirname "$0")" && pwd)
TOOL_NAME="$(basename "$TOOL_DIR")"
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

"$DOTFILES_DIR"/brew/install_itself.sh

# Preinstalled git in MacOS is called `Apple Git`, which is not useful.
# `brew git` has zsh completions.
brew install git
brew install gibo
brew install pre-commit

CONFIG_DIR="$HOME/.config/git"
mkdir -p "$CONFIG_DIR"
ln -sfn "$TOOL_DIR/gitignore_global" "$CONFIG_DIR/ignore"
ln -sfn "$TOOL_DIR/gitconfig" "$HOME/.gitconfig"

set -x
ln -sfn "$TOOL_DIR/zshrc" "$DOTFILES_DIR/zsh/zshrc.d/$TOOL_NAME.zshrc"
set +x
