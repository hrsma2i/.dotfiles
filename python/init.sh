#!/bin/bash -eu

PROJECT_NAME=$1

TOOL_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES_DIR=$(cd "$TOOL_DIR/.." && pwd)

"$TOOL_DIR/install.sh"

if [ -d "$PROJECT_NAME" ]; then
    echo "$PROJECT_NAME already exists"
else
    uv init "$PROJECT_NAME"
fi
PROJECT_DIR=$(cd "$PROJECT_NAME" && pwd)

# overwrite .gitignore
# copier 使うなら不要？
"$DOTFILES_DIR/git/install.sh"
gibo dump python > "$PROJECT_DIR/.gitignore"

# add ruff
pushd "$PROJECT_DIR"
uv add --dev ruff

# TODO: mypy も入れる？

# TODO: init pre-commit
# copier 使うのがいい？

# TODO: init github actions
# copier 使うのがいい？

