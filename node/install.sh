#!/bin/bash -eu
TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_DIR/shared/install_if_not_exists.sh"

install_node() {
    NODE_VERSION=22
    "$DOTFILES_DIR"/mise/install.sh

    mise install node@$NODE_VERSION
    mise use -g node@$NODE_VERSION
}

install_if_not_exists node install_node
