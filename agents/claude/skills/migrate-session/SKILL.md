---
name: migrate-session
description: "TRIGGER when: 別のディレクトリで作られた Claude Code の session を、現在のディレクトリに引き継いで再開したいと頼まれた（リポジトリの切り出し・移動・改名後など）。DO NOT TRIGGER when: 同じディレクトリの session を再開するだけのとき（`/resume` で足りる）。"
---

# 他のディレクトリの session を引き継ぐ

session は `~/.claude/projects/<エンコード済みパス>/<session-id>.jsonl` に保存され、`/resume` には現在のディレクトリに対応する保存先のものしか出ない。引き継ぐには jsonl を現在のディレクトリの保存先へコピーする。

## 手順

1. 現在のディレクトリの保存先を確認する。パスの `/` と `.` を `-` に置換した名前になる（例: `/Users/a.b/diggram` → `-Users-a-b-diggram`）
2. コピー元の保存先を探す。ユーザーが元ディレクトリを言わない場合は `ls -d ~/.claude/projects/*<キーワード>*` で候補を探し、見つからなければユーザーに聞く（AskUserQuestion）
3. コピー元の session を絞る。更新日時順に並べ、各 jsonl の `customTitle` / `aiTitle` と、現在のリポジトリ名の出現回数（`grep -c`）を集計する。出現回数が多く、タイトルが目的に合うものが候補
4. 候補が複数あれば AskUserQuestion で選んでもらう
5. `cp -n <元>/<session-id>.jsonl <現在の保存先>/` でコピーする（`-n` で上書きを避ける。元は消さない）
6. ユーザーに再開方法を案内する

## 注意

- Claude は実行中の session を切り替えられない。再開はユーザーが `claude --resume <session-id>` か `/resume` で行う（VSCode 拡張でも `/resume` が使える）
- 記録には元のパスが残る。再開後に古いパスを参照したら、ユーザーに伝える
- jsonl は数 MB〜数十 MB になる。中身を丸ごと読まず、`grep` / `cut` で必要な行だけ見る
