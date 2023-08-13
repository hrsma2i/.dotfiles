#!/bin/sh -eu

# https://ics.media/entry/4682/
# https://typescript-jp.gitbook.io/deep-dive/nodejs
# https://qiita.com/notakaos/items/3bbd2293e2ff286d9f49

project_name=$1
mkdir "$project_name"
cd "$project_name" || exit
npm init -y
npm install --save-dev typescript
npm install --save-dev @types/node
npx tsc --init --rootDir src \
    --outDir lib \
    --esModuleInterop \
    --resolveJsonModule \
    --lib es6,dom \
    --module commonjs
npm install --save-dev ts-node
npm install --save-dev nodemon
git init
gibo dump Node >.gitignore
