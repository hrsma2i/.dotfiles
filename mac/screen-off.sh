#!/bin/bash -eu
# ディスプレイだけをオフにし、Mac 自体はスリープさせずに処理を続ける。

# 引数まで完全一致させる。`pgrep -x caffeinate` だと他のプロセスが起動した時間制限つき（例: 300 秒）の
# caffeinate を拾い、時間制限なしのものが起動されない。時間制限つきのものは別のプロセスが使っているので止めない。
CAFFEINATE_ARGS='-i -s'

pgrep -fx "caffeinate $CAFFEINATE_ARGS" >/dev/null || (nohup caffeinate $CAFFEINATE_ARGS >/dev/null 2>&1 &)

# displaysleepnow だけだと、無操作が続くと Mac 自体がスリープするので、必ず caffeinate を先に起動する。
pmset displaysleepnow

sleep 1
pmset -g assertions | grep -E 'PreventUserIdleSystemSleep|PreventSystemSleep|caffeinate|Details' || true
pgrep -lfx "caffeinate $CAFFEINATE_ARGS"

if pmset -g batt | head -1 | grep -q 'Battery Power'; then
    echo "バッテリー駆動中は -s が効かない。電源接続を推奨する。"
fi

echo "時間制限なしの caffeinate を起動したままにしている。作業後に止める: pkill -fx 'caffeinate $CAFFEINATE_ARGS'"
echo "蓋を閉じるとスリープして処理が止まる。画面を戻すにはマウスかキーボードに触れる。"
