---
name: launch-session
description: "TRIGGER when: 別の claude セッションを、auto mode かつ remote-control（iOS アプリなどから操作・承認できる状態）でバックグラウンドに立ち上げたいと頼まれた。DO NOT TRIGGER when: このセッション内で作業を続けるとき; or サブエージェントで足りるとき。"
---

# 別セッションを auto mode ＋ remote-control で立ち上げる

`launch.sh` が `claude "<プロンプト>" --bg --remote-control "<名前>" --permission-mode auto` を実行する。

## 使い方（2 段階。引数は JSON に固定）

### 1. 確認の質問を作る

`~/.claude/skills/launch-session/launch.sh ask '{"summary": "プロンプトの要点", "dirs": ["~/x"], "names": ["案1", "案2"]}'`

- 出力（`{"questions": [...]}`）を、そのまま AskUserQuestion の引数にする。1 問目がディレクトリ、2 問目がセッション名、先頭の候補が推定案（Recommended）で、パスは `~` 表記になる。形式はスクリプトが固定するので、手で組み立てない。
- `dirs`（1〜4 件）: 依頼文のパスやリポジトリ名から推定した作業ディレクトリ。1 件のときは、カレントディレクトリが候補に足される。
- `names`（2〜4 件）: セッション名の案。ユーザーが依頼文で言った名前はそのまま 1 件目に入れる。英訳・言い換え・省略をしない。言っていなければ、依頼内容が分かる短い日本語の名前を案にする。セッション名は日本語必須で、ひらがな・カタカナ・漢字を 1 文字も含まない名前はスクリプトが拒否する（固有名詞の英字は混ぜてよい）。

### 2. 起動する

AskUserQuestion の回答を使って起動する。

`~/.claude/skills/launch-session/launch.sh '{"name": "...", "dir": "~/...", "prompt": "...", "confirmed": true, "options": ["..."]}'`

- `name`（必須）: 回答で選ばれたセッション名
- `dir`（必須）: 回答で選ばれた作業ディレクトリ。`~` で書く（ユーザー名を展開したパスは拒否される）。存在しなければエラーで終わる
- `prompt`（必須）: 新しいセッションへの指示。単独で読んで動けるように、背景・対象ファイル・やってほしいこと・終了条件を書く。このセッションの会話は引き継がれない
- `confirmed`（必須）: AskUserQuestion の回答を得たあとだけ `true` にする。無いと起動しない
- `options`（省略可）: claude に渡す追加オプションの配列。許可するコマンドを絞るなら `["--allowedTools", "Bash(<コマンド>)"]`
- プロンプトに引用符や改行が多いときは、JSON をファイルに書き、`launch.sh - < file.json` で標準入力から渡す。

## main で作業させたいとき

`--bg` のジョブは既定で、隔離ガードにより main などの共有チェックアウトを編集できない。`launch.sh` は起動前に、作業ディレクトリの `.claude/settings.local.json`（コミット対象外）へ `"worktree": {"bgIsolation": "none"}` を書いてガードを外すので、main で編集・commit できる（commit は試験済み。push は未確認）。

- 記録（jsonl）は作業ディレクトリの保存先に残る。mac で `cd <作業ディレクトリ>` して `/resume` で引き継げる。
- main への push は、プロンプトでユーザーが明示したときだけ書く。

## 起動後

- `backgrounded · <id>` と出れば起動している。
  - `claude agents`: セッションの一覧
  - `claude logs <id>`: 直近の出力
  - `claude attach <id>`: このターミナルで開く
  - `claude stop <id>`: 止める
- ユーザーへの質問が要る処理は、プロンプトに「AskUserQuestion で聞く」と書くと、iOS アプリに届く。

## 注意

- auto mode は、許可の確認を自動で判断して進める。破壊的な操作や外部への送信をさせたくない場合は、プロンプトで範囲を絞るか `--allowedTools` で制限する。
- 初めて使うディレクトリでは「Workspace not trusted」で起動できない。`launch.sh` が起動前に `~/.claude.json` の該当ディレクトリへ `hasTrustDialogAccepted: true` を書き込んで trust するので、対話での承認は不要。
