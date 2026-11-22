---
name: launch-session
description: "TRIGGER when: 別の claude セッションを、auto mode かつ remote-control（iOS アプリなどから操作・承認できる状態）でバックグラウンドに立ち上げたいと頼まれた。DO NOT TRIGGER when: このセッション内で作業を続けるとき; or サブエージェントで足りるとき。"
---

# 別セッションを auto mode ＋ remote-control で立ち上げる

`launch.sh` が `claude "<プロンプト>" --bg --remote-control "<名前>" --permission-mode auto` を実行する。

## 使い方

`~/.claude/skills/launch-session/launch.sh <セッション名> <作業ディレクトリ> <プロンプト> [claude に渡す追加オプション...]`

1. セッション名は引数で受ける。ユーザーが指定していなければ、内容が分かる短い名前を付ける。
2. 作業ディレクトリは引数で受ける。存在しなければエラーで終わる。ユーザーが指定していなければ、このセッションのカレントディレクトリを渡す。
3. プロンプトは、新しいセッションが単独で読んで動けるように、背景・対象ファイル・やってほしいこと・終了条件を書く。このセッションの会話は引き継がれない。
4. 追加オプションは、プロンプトのあとに渡す。許可するコマンドを絞るなら `--allowedTools "Bash(<コマンド>)"` を付ける。

## main で作業させたいとき

`--bg` のジョブは、ワークツリーでしか編集できず、main への commit・push も禁じられる。main で作業させるときは、`LAUNCH_MODE=interactive` を付けて起動する。`screen` の中で通常の対話セッションとして動き、remote-control には同じ名前で出る。

`LAUNCH_MODE=interactive ~/.claude/skills/launch-session/launch.sh <セッション名> <作業ディレクトリ> <プロンプト>`

- 一覧は `screen -ls`、開くのは `screen -r <セッション名>`(抜けるのは Ctrl-a d)、止めるのは `screen -S <セッション名> -X quit`。
- `claude agents` の一覧には出ない。
- 初回の確認画面(信頼するか、など)が出ると、そこで止まる。起動後に `screen -r` で状態を確かめる。
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
