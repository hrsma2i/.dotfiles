---
name: commit
description: "TRIGGER when: git commit を依頼された（ステージング・変更の分割も任せる）。DO NOT TRIGGER when: PR の作成や push だけを頼まれたとき。"
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git add:*) Bash(git commit:*)
---

変更内容を確認し、必要ならステージング（`git add`）も行って git commit する。

## 手順

1. `git status` と `git diff`（ステージ済みは `git diff --cached`）で変更内容を把握する
2. すでにステージ上にファイルがある場合は、ユーザーが意図してステージしたものとみなし、その内容を尊重する（勝手に unstage しない）
3. 変更を commit 単位に分ける
   - 目的が異なる変更が混ざっている場合は、目的ごとに別の commit に分ける
   - 1 つの目的に閉じている変更は無理に分けない
   - 同一ファイル内に複数の目的の変更が混ざっている場合は `git add -p` 等で hunk 単位に分ける
4. commit 単位ごとに「`git add` → `git commit`」を繰り返す
5. 完了後、ユーザーに報告する

## ユーザーへの報告

commit 後に、日本語で表にして伝える。列は次の 3 つ。

- commit hash（短縮形）
- message
- どういう単位で分けたか（含めたファイルと、その単位にした理由。分けなかった場合はその旨）

## コミットメッセージのルール

1. 英語を使う
2. 文頭は小文字始まりにする（※固有名詞等は例外）
3. 1 行に収まる簡潔なメッセージにする
4. 「何を変えたか」ではなく「何のための変更か（目的）」を書く
   - ok: `fix bug where users cannot log in with an expired session`
   - ng: `remove unused variable foo`
5. 以下のフレーズは厳禁
   - `feat:`, `refactor:` などの prefix
   - `🤖 Generated with [Claude Code](https://claude.ai/code)`
   - `Co-Authored-By: Claude <noreply@anthropic.com>`
