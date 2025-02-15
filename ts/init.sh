#!/bin/sh -eu

PROJECT_NAME=$1

TOOL_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES_DIR=$(cd "$TOOL_DIR/.." && pwd)

# node がなければインストール
"$DOTFILES_DIR/node/install.sh"

# https://ics.media/entry/4682/
# https://typescript-jp.gitbook.io/deep-dive/nodejs
# https://qiita.com/notakaos/items/3bbd2293e2ff286d9f49
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

npm init -y

# TypeScript と Node の型定義をインストール
npm install --save-dev typescript @types/node

# コンパイルの設定である tsconfig.json を生成
npx tsc --init --rootDir src \
    --outDir lib \
    --esModuleInterop \
    --resolveJsonModule \
    --lib es6,dom \
    --module commonjs

# `npx ts-node src/index.ts` で直接実行できるようにする
npm install --save-dev ts-node
# TODO: nodemon はファイル検知してサーバーをリロードするツールだけど、すべてのプロジェクトで必要なわけではないので、必要なプロジェクトを見極めてから自動化する。
# npm install --save-dev nodemon

# git がなければインストール
"$DOTFILES_DIR/git/install.sh"
git init
gibo dump Node >.gitignore
