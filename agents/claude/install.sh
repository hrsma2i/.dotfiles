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

# commands ディレクトリを ~/.claude/commands にシンボリックリンク
ln -sfn "$TOOL_DIR/commands" ~/.claude/commands

# agents ディレクトリを ~/.claude/agents にシンボリックリンク
ln -sfn "$TOOL_DIR/agents" ~/.claude/agents

# settings.json を生成（共通設定 + マシン固有設定をマージ）
"$TOOL_DIR/sync_settings.sh"

echo "Claude Code has been installed and configured."
echo "AGENTS.md has been symlinked to ~/.claude/CLAUDE.md"
echo "commands directory has been symlinked to ~/.claude/commands"
echo "agents directory has been symlinked to ~/.claude/agents"
echo "settings.json has been generated from base + local settings"
