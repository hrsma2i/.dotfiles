#!/bin/bash -eu

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.claude

if [ -f ~/.claude/settings.local.json ]; then
    jq -s '.[0] * (.[1] // {})' "$TOOL_DIR/settings.json" ~/.claude/settings.local.json > ~/.claude/settings.json
else
    cp "$TOOL_DIR/settings.json" ~/.claude/settings.json
fi

echo "settings.json has been generated from base + local settings"
