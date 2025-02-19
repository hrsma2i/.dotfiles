#!/bin/bash -eu

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_DIR/shared/install_if_not_exists.sh"

install_clasp() {
    "$DOTFILES_DIR/node/install.sh"

    npm install -g @google/clasp
}

install_if_not_exists clasp install_clasp

if [ -s "$HOME/.clasprc.json" ]; then
    echo "You have already logged in clasp."
    exit 0
else
    clasp login
fi
