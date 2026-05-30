#!/bin/bash -eu
TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_DIR/shared/install_if_not_exists.sh"

install_bun() {
    curl -fsSL https://bun.sh/install | bash
}

install_if_not_exists bun install_bun
