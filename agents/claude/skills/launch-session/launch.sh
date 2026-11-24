#!/usr/bin/env python3
# 別の claude セッションを、auto mode かつ remote-control（iOS アプリ等から操作できる状態）でバックグラウンドに立ち上げる。
# 使い方: launch.sh ask '<JSON>'  … AskUserQuestion の引数を出力する。JSON: {"summary": "プロンプトの要点", "dirs": ["~/x", ...], "names": ["案1", "案2", ...]}
#         launch.sh '<JSON>'      … 起動する（JSON は 1 つの引数。標準入力からも読める: launch.sh - < file.json）
# JSON: {"name": "セッション名", "dir": "~/作業ディレクトリ", "prompt": "プロンプト", "confirmed": true, "options": ["追加オプション", ...]}
# name・dir・prompt・confirmed は必須、options は省略可。dir は ~ で書く（展開済みのパスは拒否）。confirmed は ask の確認後だけ true。作業ディレクトリは起動前に ~/.claude.json で trust 済みにする（未設定なら自動で設定する）。
import json
import os
import re
import sys

HOME = os.path.expanduser("~")


def tilde(p):
    return "~" + p[len(HOME):] if p == HOME or p.startswith(HOME + "/") else p


def load(raw):
    try:
        return json.loads(sys.stdin.read() if raw == "-" else raw)
    except json.JSONDecodeError as e:
        sys.exit(f"JSON が不正です: {e}")


def require_japanese(name):
    # セッション名が勝手に英語になるのを防ぐ。固有名詞の英字は混ぜてよいが、ひらがな・カタカナ・漢字を 1 文字は含める
    if not re.search(r"[\u3040-\u30ff\u4e00-\u9fff]", name):
        sys.exit(f"セッション名は日本語にしてください: {name}")


def check_keys(args, required, optional):
    missing = [k for k in required if not args.get(k)]
    unknown = sorted(set(args) - set(required) - set(optional))
    if missing or unknown:
        sys.exit(f"JSON のキーが不正です。不足: {missing} / 未知: {unknown}")


def str_list(v, key, lo, hi):
    if not isinstance(v, list) or not all(isinstance(x, str) and x.strip() for x in v) or not lo <= len(v) <= hi:
        sys.exit(f"{key} は空でない文字列の配列（{lo}〜{hi} 件）にしてください")
    return v


# 起動前の確認（AskUserQuestion）の形を固定する。1 問目がディレクトリ、2 問目がセッション名。先頭の候補が推定案。
# 出力をそのまま AskUserQuestion の引数にする。パスは ~ で表示する
if len(sys.argv) == 3 and sys.argv[1] == "ask":
    args = load(sys.argv[2])
    check_keys(args, ["summary", "dirs", "names"], [])
    dirs = [tilde(os.path.abspath(os.path.expanduser(d))) for d in str_list(args["dirs"], "dirs", 1, 4)]
    names = str_list(args["names"], "names", 2, 4)
    for n in names:
        require_japanese(n)

    def question(header, label, values, desc):
        return {
            "header": header,
            "question": f"{label}\n{args['summary']}",
            "multiSelect": False,
            "options": [{"label": v + (" (Recommended)" if i == 0 else ""), "description": desc} for i, v in enumerate(values)],
        }

    cwd = tilde(os.getcwd())
    if len(dirs) < 2:
        dirs.append(cwd if cwd != dirs[0] else tilde(HOME))
    print(json.dumps({"questions": [question("ディレクトリ", "作業ディレクトリは？", dirs, "作業ディレクトリ"), question("セッション名", "セッション名は？", names, "セッション名")]}, ensure_ascii=False, indent=2))
    sys.exit(0)

if len(sys.argv) != 2:
    sys.exit("使い方: launch.sh '<JSON>' / launch.sh ask '<JSON>'")

args = load(sys.argv[1])
check_keys(args, ["name", "dir", "prompt", "confirmed"], ["options"])
options = args.get("options", [])
if args["confirmed"] is not True:
    sys.exit('confirmed は true のみ。ask の出力を AskUserQuestion で確認してから true にして起動する')
if not all(isinstance(args[k], str) for k in ("name", "dir", "prompt")):
    sys.exit("name・dir・prompt は文字列にしてください")
str_list(options, "options", 0, 1000) if options else None
if args["dir"] == HOME or args["dir"].startswith(HOME + "/"):
    sys.exit(f"dir は ~ で書く（例: {tilde(args['dir'])}）。ユーザー名を展開したパスは受け付けない")

require_japanese(args["name"])
name, prompt = args["name"], args["prompt"]
dir_ = os.path.abspath(os.path.expanduser(args["dir"]))
if not os.path.isdir(dir_):
    sys.exit(f"作業ディレクトリが存在しません: {dir_}")
os.chdir(dir_)

# 初めて使うディレクトリは「Workspace not trusted」で起動できないため、~/.claude.json の trust フラグをファイル操作で立てる
path = os.path.expanduser("~/.claude.json")
data = json.load(open(path))
entry = data.setdefault("projects", {}).setdefault(dir_, {})
if not entry.get("hasTrustDialogAccepted"):
    entry["hasTrustDialogAccepted"] = True
    json.dump(data, open(path, "w"), ensure_ascii=False, indent=2)

# --bg のジョブは既定で、共有チェックアウト（main など）への編集を隔離ガードが拒否し、ワークツリーを強制する。
# main で commit・push させるため、作業ディレクトリの settings.local.json（コミット対象外）でガードを外す
path = os.path.join(dir_, ".claude", "settings.local.json")
data = json.load(open(path)) if os.path.exists(path) else {}
wt = data.setdefault("worktree", {})
if wt.get("bgIsolation") != "none":
    wt["bgIsolation"] = "none"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    json.dump(data, open(path, "w"), ensure_ascii=False, indent=2)

# --allowedTools など値を複数取るオプションが、続く位置引数（プロンプト）を値として食べてしまうので、プロンプトを先頭に置く
os.execvp("claude", ["claude", prompt, "--bg", "--remote-control", name, "--name", name, "--permission-mode", "auto", *options])
