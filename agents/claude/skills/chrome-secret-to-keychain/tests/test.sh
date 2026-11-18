#!/bin/bash -eu
# 偽の値だけを入れたローカル HTML で、inspect が値を出さないこと、伏せ字のキーを隣のキーと取り違えないこと、
# 表示ボタンを押して正しい値を Keychain に入れることを確認する。
# 実在のサイトには接続しない。専用 Chrome（9222）にも触れず、使い捨てのヘッドレス Chrome（9333）を使う。
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$TESTS_DIR/../save-secret.ts"
REGISTRY="$TESTS_DIR/test-registry.json"
WORK="$(mktemp -d)"
SERVICE=dotfiles-test-chrome-secret
EXPECTED=FAKEWRITEKEY00000000000000000000
# 短い偽の Application ID は伏せない仕様なので、キーに当たる偽の値だけを漏洩の検査対象にする
KEY_FAKES="FAKESEARCHKEY|FAKEWRITEKEY|FAKEANALYTICSKEY|FAKEIDLEAK|FAKETABLEKEY|FAKEOTHERROWKEY"
cleanup() {
    kill "${CHROME_PID:-}" "${HTTP_PID:-}" 2>/dev/null || true
    security delete-generic-password -a "$USER" -s "$SERVICE" >/dev/null 2>&1 || true
    rm -rf "$WORK"
}
trap cleanup EXIT

python3 -I -m http.server 8765 --bind 127.0.0.1 --directory "$TESTS_DIR" >/dev/null 2>&1 &
HTTP_PID=$!
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --remote-debugging-port=9333 \
    --user-data-dir="$WORK/profile" http://127.0.0.1:8765/fixture.html >/dev/null 2>&1 &
CHROME_PID=$!
for _ in $(seq 1 30); do
    curl -s http://127.0.0.1:9333/json/version >/dev/null && break
    sleep 1
done
sleep 2

echo "--- inspect"
node "$SCRIPT" inspect fixture-write-key --port 9333 --registry "$REGISTRY" >"$WORK/inspect.out"
if grep -qE "$KEY_FAKES" "$WORK/inspect.out"; then
    echo "NG: inspect の出力に偽の値が含まれています"
    exit 1
fi
echo "OK: inspect の出力に値は含まれない"

echo "--- save（表示ボタンなし。伏せ字のとき、隣の Analytics のキーを取らずに失敗すること）"
if node "$SCRIPT" save fixture-write-key-no-reveal --port 9333 --registry "$REGISTRY" >"$WORK/noreveal.out" 2>&1; then
    echo "NG: 伏せ字なのに保存が成功しました"
    exit 1
fi
if security find-generic-password -a "$USER" -s "$SERVICE" >/dev/null 2>&1; then
    echo "NG: 失敗したのに Keychain に項目ができています"
    exit 1
fi
echo "OK: 伏せ字では保存せず、隣のキーも取らない"

echo "--- save（表示ボタンあり）"
node "$SCRIPT" save fixture-write-key --port 9333 --registry "$REGISTRY" | tee "$WORK/save.out"
if grep -qE "$KEY_FAKES" "$WORK/save.out"; then
    echo "NG: save の出力に偽の値が含まれています"
    exit 1
fi
[ "$(security find-generic-password -a "$USER" -s "$SERVICE" -w)" = "$EXPECTED" ] && echo "OK: Write のキーが保存された（Search や Analytics ではない）"
echo "--- 保存後に伏せ字へ戻っていること"
node "$SCRIPT" save fixture-write-key-no-reveal --port 9333 --registry "$REGISTRY" >/dev/null 2>&1 && { echo "NG: 表示のまま残っています"; exit 1; }
echo "OK: 伏せ字に戻っている"

echo "--- save（値が見出しの前にある表の行。隣の行のキーではなく、見出しに最も近いものを取ること）"
node "$SCRIPT" save fixture-table-row --port 9333 --registry "$REGISTRY" | tee "$WORK/table.out"
if grep -qE "$KEY_FAKES" "$WORK/table.out"; then
    echo "NG: save の出力に偽の値が含まれています"
    exit 1
fi
[ "$(security find-generic-password -a "$USER" -s "$SERVICE" -w)" = "FAKETABLEKEY00000000000000000000" ] && echo "OK: 表の行のキーが保存された（隣の行ではない）"

echo "--- save（表の行のキーが形式に合わないとき。手前の別の行のキーを取らずに失敗すること）"
security delete-generic-password -a "$USER" -s "$SERVICE" >/dev/null 2>&1 || true
if node "$SCRIPT" save fixture-table-bad-row --port 9333 --registry "$REGISTRY" >"$WORK/bad.out" 2>&1; then
    echo "NG: 形式に合わないのに保存が成功しました"
    exit 1
fi
if security find-generic-password -a "$USER" -s "$SERVICE" >/dev/null 2>&1; then
    echo "NG: 失敗したのに Keychain に項目ができています"
    exit 1
fi
echo "OK: 形式に合わないときは、手前の別のキーを取らずに失敗する"
