---
name: commit
description: "TRIGGER when: git commit を依頼された（ステージング・変更の分割も任せる）。DO NOT TRIGGER when: PR の作成や push だけを頼まれたとき。"
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git add:*) Bash(git commit:*) Bash(git apply --cached:*)
---

変更内容を確認し、必要ならステージング（`git add`）も行って git commit する。

## 手順

1. `git status` と `git diff`（ステージ済みは `git diff --cached`）で変更内容を把握する
2. すでにステージ上にファイルがある場合は、ユーザーが意図してステージしたものとみなし、その内容を尊重する（勝手に unstage しない）
3. この会話の作業と無関係な変更（他のセッションやユーザー自身の編集）が混ざっていないか確認する
   - 判断は、この会話で自分が編集したファイル・行と、依頼されたトピックとの関連で行う。関連のない diff は、ファイル単位でも hunk 単位でも staged に入れない
   - 混ざっていたら、関連のある行だけを staged にして commit する。関連のない変更は作業ツリーに残し、触らない（stash・checkout・reset で消さない）
   - ユーザーが「この diff だけ」と範囲を指定したときは、その指定に従う
4. 変更を commit 単位に分ける
   - 目的が異なる変更が混ざっている場合は、目的ごとに別の commit に分ける
   - 1 つの目的に閉じている変更は無理に分けない
   - 同一ファイル内に複数の目的の変更が混ざっている場合は hunk 単位に分ける。`git add -p` は対話式で使えないので、`git diff -U0 <file>` を hunk ごとに選んで patch を作り、`git apply --cached --unidiff-zero <patch>` で staged にする。隣り合う行に関連のある変更と無関係な変更が混ざる hunk（import 行など）は、patch を手で書き直して関連のある行だけにする
   - staged にしたあと `git diff --cached` を読み、関連のない変更が入っていないことを確認してから commit する
5. commit 単位ごとに「staged にする → `git commit`」を繰り返す
6. 完了後、ユーザーに報告する

## ユーザーへの報告

commit 後に、日本語で表にして伝える。列は次の 3 つ。

- commit hash（短縮形）
- message
- どういう単位で分けたか（含めたファイルと、その単位にした理由。分けなかった場合はその旨）

関連のない変更を commit から外したときは、表の後にそのファイル・hunk を挙げて、staged にも commit にも入れていないことを伝える。外した変更と commit した変更が依存しあう（型や参照など）場合は、その旨も伝える。

## コミットメッセージのルール

1. 英語を使う
2. 文頭は小文字始まりにする（※固有名詞等は例外）
3. 1 行に収まる簡潔なメッセージにする
4. 「何を変えたか」ではなく「何のための変更か（目的）」を書く
   - ok: `fix bug where users cannot log in with an expired session`
   - ng: `remove unused variable foo`
5. 以下のフレーズは厳禁
   - `feat:`, `refactor:` などの prefix
