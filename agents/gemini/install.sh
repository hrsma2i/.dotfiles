#!/bin/bash -eu

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TOOL_DIR"/../.. && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_DIR/shared/install_if_not_exists.sh"

install_gemini_cli() {
    "$DOTFILES_DIR/node/install.sh"

    npm install -g @google/gemini-cli
}

install_if_not_exists gemini install_gemini_cli

# AGENTS.md を ~/.gemini/GEMINI.md にシンボリックリンク
mkdir -p ~/.gemini
ln -sfn "$DOTFILES_DIR/agents/AGENTS.md" ~/.gemini/GEMINI.md

echo "Gemini CLI has been installed and configured."
echo "AGENTS.md has been symlinked to ~/.gemini/GEMINI.md"
