#!/bin/bash -eu

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TOOL_DIR"/../.. && pwd)"

# shellcheck disable=SC1091
source "$DOTFILES_DIR/shared/install_if_not_exists.sh"

install_claude_code() {
    "$DOTFILES_DIR/node/install.sh"

    npm install -g @anthropic-ai/claude-code
}

install_if_not_exists claude install_claude_code

# AGENTS.md を ~/.claude/CLAUDE.md にシンボリックリンク
mkdir -p ~/.claude
ln -sfn "$DOTFILES_DIR/agents/AGENTS.md" ~/.claude/CLAUDE.md

echo "Claude Code has been installed and configured."
echo "AGENTS.md has been symlinked to ~/.claude/CLAUDE.md"
