#!/bin/bash
# 別の claude セッションを、auto mode かつ remote-control（iOS アプリ等から操作できる状態）でバックグラウンドに立ち上げる。
# 使い方: launch.sh <セッション名> <作業ディレクトリ> <プロンプト> [claude に渡す追加オプション...]
# 作業ディレクトリは起動前に ~/.claude.json で trust 済みにする（未設定なら自動で設定する）。
set -eu

if [ "$#" -lt 3 ]; then
  echo "使い方: $(basename "$0") <セッション名> <作業ディレクトリ> <プロンプト> [claude に渡す追加オプション...]" >&2
  exit 2
fi

name=$1
dir=$2
prompt=$3
shift 3

if [ ! -d "$dir" ]; then
  echo "作業ディレクトリが存在しません: $dir" >&2
  exit 2
fi
cd "$dir"

# 初めて使うディレクトリは「Workspace not trusted」で起動できないため、~/.claude.json の trust フラグをファイル操作で立てる
python3 - "$PWD" <<'EOF'
import json, os, sys
path = os.path.expanduser('~/.claude.json')
key = sys.argv[1]
data = json.load(open(path))
entry = data.setdefault('projects', {}).setdefault(key, {})
if not entry.get('hasTrustDialogAccepted'):
    entry['hasTrustDialogAccepted'] = True
    json.dump(data, open(path, 'w'), ensure_ascii=False, indent=2)
EOF

# --allowedTools など値を複数取るオプションが、続く位置引数（プロンプト）を値として食べてしまうので、プロンプトを先頭に置く
#
# LAUNCH_MODE=interactive のときは、--bg を使わず、screen の中で通常の対話セッションとして動かす。
# --bg のジョブは、main への commit・push が禁じられ、ワークツリーでしか編集できない。main で作業させたいときはこちらを使う
if [ "${LAUNCH_MODE:-bg}" = interactive ]; then
  exec screen -dmS "$name" claude "$prompt" --remote-control "$name" --permission-mode auto "$@"
fi
exec claude "$prompt" --bg --remote-control "$name" --permission-mode auto "$@"
