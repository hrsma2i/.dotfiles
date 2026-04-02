---
description: ステージ上のファイルをコミット
---

すでにステージ上にあるファイルのみ git commit を行います。
`git add`, `git status`, `git diff` はユーザーから指示がない限り使わない。

## コミットメッセージのルール

1. 英語を使う
2. 文頭は小文字始まりにする（※固有名詞等は例外）
3. 1 行に収まる簡潔なメッセージにする
4. 以下のフレーズは厳禁
   - `feat:`, `refactor:` などの prefix
   - `🤖 Generated with [Claude Code](https://claude.ai/code)`
   - `Co-Authored-By: Claude <noreply@anthropic.com>`
