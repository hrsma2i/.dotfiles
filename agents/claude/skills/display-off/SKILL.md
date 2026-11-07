---
name: display-off
description: TRIGGER when: 「画面だけ暗くして」「画面だけオフ」など、Mac のディスプレイだけを消して作業（長いタスクやバックグラウンド処理）は動かし続けたいと頼まれたとき。DO NOT TRIGGER when: Mac 全体をスリープさせたいとき or 明るさを下げるだけのとき。
---

ディスプレイだけをオフにし、Mac 自体はスリープさせずに処理を続ける。

## 手順

1. スリープ防止を時間制限なしで起動する（時間制限なしのものがすでに動いていれば起動しない）。

   ```
   pgrep -fx 'caffeinate -i -s' >/dev/null || (nohup caffeinate -i -s >/dev/null 2>&1 &)
   ```

   - 判定は `-fx` で引数まで完全一致させる。`pgrep -x caffeinate` だと、他のプロセスが起動した時間制限つき（例: 300 秒）の `caffeinate` を拾い、時間制限なしのものが起動されない。
   - 時間制限つきの `caffeinate` は止めない。別のプロセスが使っている。
   - `-i`: 無操作によるスリープを防ぐ
   - `-s`: 電源接続中のシステムスリープを防ぐ（バッテリー駆動中は効かない）
2. ディスプレイだけをスリープさせる。

   ```
   pmset displaysleepnow
   ```
3. 効いているか確認する。`PreventUserIdleSystemSleep` が 1 で、`caffeinate -i -s` が 1 つだけ（`asserting forever`）なら有効。

   ```
   pmset -g assertions | grep -E 'PreventUserIdleSystemSleep|PreventSystemSleep|caffeinate|Details'
   pgrep -fx 'caffeinate -i -s'
   ```

## 注意

- `pmset displaysleepnow` だけでは、無操作が続くと Mac 自体がスリープして処理が止まる。必ず手順 1 のスリープ防止を先に起動する。
- スリープ防止は時間制限なし。作業が終わったら、ユーザーに止めるか確認し、止めるときは `pkill -fx 'caffeinate -i -s'` を実行する。起動したままにしてよいかは、毎回ユーザーに伝える。
- バッテリー駆動中は `-s` が効かないので、電源接続をユーザーに勧める。
- 画面を戻すには、マウスかキーボードに触れる。
