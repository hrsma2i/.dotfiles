#!/bin/bash -eu
# NOTE: プロジェクトディレクトリは自分で作り、その中でこのスクリプトを実行する
# NOTE: 冪等になってないので注意

PROJECT=$1

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TOOL_DIR"/.. && pwd)"

"$DOTFILES_DIR/clasp/install.sh"
"$DOTFILES_DIR/git/install.sh"

clasp create --title "$PROJECT"

npm install @types/google-apps-script

gibo dump Node >.gitignore
echo ".clasp.json" >>.gitignore

git init
