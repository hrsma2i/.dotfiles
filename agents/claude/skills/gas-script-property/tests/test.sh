#!/bin/bash -eu
# 偽のページと偽の値だけで、出力に値が出ないこと、既存プロパティを黙って上書きしないこと、
# 正しい名前と値が入ることを確認する。実在のサイトにも専用 Chrome（9222）にも触れず、使い捨てのヘッドレス Chrome（9334）を使う。
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$TESTS_DIR/../set-script-property.ts"
WORK="$(mktemp -d)"
SERVICE=dotfiles-test-gas-script-property
FAKE=FAKEGEMINIKEY0000000000000000000000000
COMMON=(--port 9334 --host 127.0.0.1 --path-includes fixture)
cleanup() {
    kill "${CHROME_PID:-}" "${HTTP_PID:-}" 2>/dev/null || true
    security delete-generic-password -a "$USER" -s "$SERVICE" >/dev/null 2>&1 || true
    rm -rf "$WORK"
}
trap cleanup EXIT

security add-generic-password -U -a "$USER" -s "$SERVICE" -w "$FAKE"
python3 -I -m http.server 8766 --bind 127.0.0.1 --directory "$TESTS_DIR" >/dev/null 2>&1 &
HTTP_PID=$!
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --remote-debugging-port=9334 \
    --user-data-dir="$WORK/profile" http://127.0.0.1:8766/fixture.html >/dev/null 2>&1 &
CHROME_PID=$!
for _ in $(seq 1 30); do
    curl -s http://127.0.0.1:9334/json/version >/dev/null && break
    sleep 1
done
sleep 2
title() { curl -s http://127.0.0.1:9334/json | python3 -I -c "import sys,json; print([t['title'] for t in json.load(sys.stdin) if t['type']=='page'][0])"; }

echo "--- inspect（偽の値が出ないこと）"
node "$SCRIPT" inspect "${COMMON[@]}" >"$WORK/inspect.out"
if grep -qE "FAKE" "$WORK/inspect.out"; then
    echo "NG: inspect の出力に偽の値が含まれています"
    exit 1
fi
echo "OK: inspect の出力に値は含まれない"

echo "--- set（既存のプロパティ名は、--overwrite なしで失敗し、何も保存しないこと）"
if node "$SCRIPT" set EXISTING_KEY "$SERVICE" "${COMMON[@]}" >"$WORK/exists.out" 2>&1; then
    echo "NG: 既存のプロパティなのに成功しました"
    exit 1
fi
[ "$(title)" = "fixture" ] && echo "OK: 既存のプロパティは上書きされない"

echo "--- set（新しいプロパティを追加して保存）"
node "$SCRIPT" set GEMINI_API_KEY "$SERVICE" "${COMMON[@]}" | tee "$WORK/set.out"
if grep -qE "FAKE" "$WORK/set.out"; then
    echo "NG: set の出力に偽の値が含まれています"
    exit 1
fi
[ "$(title)" = "SAVED:EXISTING_KEY=FAKEEXISTINGVALUE00000000,GEMINI_API_KEY=$FAKE" ] && echo "OK: 新しい行に名前と値が入り、既存の行は変わらない"

echo "--- set --overwrite（既存の行の値だけを置き換える）"
node "$SCRIPT" set EXISTING_KEY "$SERVICE" --overwrite "${COMMON[@]}" >/dev/null
[ "$(title)" = "SAVED:EXISTING_KEY=$FAKE,GEMINI_API_KEY=$FAKE" ] && echo "OK: 既存の行の値だけが置き換わった"
