---
name: ios-device-test
description: "TRIGGER when: iOS アプリや ShareExtension を実機にビルド・インストールして動作確認する or 実機のログを読む。DO NOT TRIGGER when: シミュレータだけで完結する確認 or macOS アプリ。"
---

## 何を確認・起動するかの判断

次の2点は、それまでの開発の文脈（直前に直したコード、ユーザーの依頼内容、共有された URL など）から判断する。文脈から決められない曖昧なときは、推測で進めずユーザーに尋ねる。

- 確認対象が iOS アプリ本体か、ShareExtension か。
- ShareExtension を試すとき、どのアプリから起動するか（共有元アプリ）。

## 実機でビルド・インストール

1. `xcodebuild ... -destination 'id=<実機のUDID>' build 2>&1 | xcbeautify | grep -E "❌|Build Succeeded|BUILD FAILED"` でビルドし、**成否を必ず確認してから**インストールする。
   - `tail` で切ると失敗を見落とし、古いバイナリを実機に入れたまま「新しいコードが動かない」原因調査に時間を溶かす。
2. `xcrun devicectl device install app --device <UDID> <.app のパス>`
3. 実機の接続状態は **`xcrun devicectl list devices`** で見る（`State` が `available (paired)` なら使える）。`xcrun xctrace list devices` は、接続済み（ワイヤレス含む）でも `Devices Offline` に出すことがあるので、接続の判断には使わない。`xctrace` で全台オフラインでも「接続されていない」とユーザーに言わず、先に `devicectl` で確かめる。
   - `devicectl` の表の Identifier は CoreDevice 用の ID。`xcodebuild -destination 'id=...'` に渡す UDID（`0000xxxx-...`）は `xcrun devicectl list devices --json-output <ファイル>` の `hardwareProperties.udid`、または `xctrace` の行から取る（Offline の行でも UDID はそのまま使える）。
   - 複数台が `available` のときは、推測せず確認する。ユーザーが機種を指定済み、または直前の文脈で決まっていればそれに従う。
   - CLAUDE.md の destination id が古くて見つからないことがある。

## ShareExtension を実アプリから起動する

- 共有元は **Safari で代用しない**。そのサービスの実アプリを使う。実アプリは共有テキストと URL を別添付で渡す、Safari と URL の形が違う（例: Prime Video は `watch.amazon.co.jp`）など、共有内容が Safari と異なる。
- 起動: `xcrun devicectl device process launch --device <UDID> --terminate-existing --payload-url <URL> <bundle id>`
- 指定されたアプリが見つからないときは、`xcrun devicectl device info apps --device <UDID>` に **`--include-all-apps`** を付けて確認する（デフォルトは開発者署名アプリのみ表示で、App Store からインストールした Google Maps 等の市販アプリは出てこない）。これでも見つからなければ Safari で代用せずユーザーに相談する。
- 共有シートのタップは自動化できないので、そこはユーザーに頼む。

| アプリ      | bundle id               |
| ----------- | ----------------------- |
| Netflix     | `com.netflix.Netflix`   |
| Prime Video | `com.amazon.aiv.AIVApp` |
| Instagram   | `com.burbn.instagram`   |

## 実機ログを自分で読む（意図した挙動をとらないときのデバッグ用）

実機ログは毎回の確認で必須ではない。意図した挙動をとらず原因が分からないときだけ、ログを仕込んだうえで `pymobiledevice3` を使って自分で読む（USB 接続が必須。`pymobiledevice3 usbmux list` で見えなければケーブルを頼む）。ほかの手段（`log stream` / `log collect --device`（sudo 必須・失敗する）/ Console.app）は使わない。

```
pymobiledevice3 syslog live --udid <UDID> --process-name <実行ファイル名> [--subsystem <subsystem>] > /tmp/xxx.txt
```

- 実行ファイル名は拡張機能なら `ShareExtension` のようにターゲット名。
- Bash の `run_in_background` で実行する。コマンド内でさらに `&` を付けない（ラッパーが即終了してプロセスだけ孤児になる）。停止は `pkill -f "syslog live"`。
- 自作の `os.Logger` は文字列補間が既定で `<private>` に伏せられる。調査用ログは `\(value, privacy: .public)` を付け、専用の subsystem を付けて `--subsystem` で絞る。SharedUtils の `logger` は伏せられる。
- SharedUtils がリモートパッケージ参照のとき、ローカルのクローンを編集しても実機のビルドには反映されない。
- 調査用ログは原因が分かったら必ず取り除く（コミットに混ぜない）。
