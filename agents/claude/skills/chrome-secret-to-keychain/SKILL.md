---
name: chrome-secret-to-keychain
description: "TRIGGER when: ログイン済みの専用 Chrome（CDP）の画面にある API キーなどの秘密を、Claude に見せずに macOS Keychain へ保存したいと頼まれた。DO NOT TRIGGER when: 秘密を画面から取らず手で入力できるとき; or 秘密ではない値の取得（operate-chrome を使う）。"
---

# Chrome の画面の秘密を Keychain に保存する

専用 Chrome（ポート 9222、`operate-chrome` と同じ起動方法）で開いているページから秘密の値を読み、Keychain に保存する。値は出力に一切出さないので、Claude の会話に入らない。

## 使い方

1. 専用 Chrome で対象ページを開き、ユーザー自身がログインしておく。
2. 登録簿 `secrets.json` に項目がなければ足す。値は書かない。

   | キー | 意味 |
   |------|------|
   | host | 取得元として許可するホスト。タブの URL のホストと完全一致で判定する |
   | label | 値の直前にある見出しの文字。この見出しの後ろで最初に現れる入力欄を、その見出しの値として読む |
   | pattern | 値の形式（正規表現）。合わなければ保存しない |
   | keychainService | Keychain の項目名。`run.sh` などが同じ名前で読む |
   | maxDistance | 見出しから何要素先まで探すか（既定 30）。省略可 |
   | direction | 値が見出しの前にある表の行などでは `"before"`（既定は `"after"`）。前方向では、見出しに最も近いキーらしい値（16 文字以上の英数字）を取り、形式が合わなければ失敗する |
   | revealSelector | 値が伏せ字のとき押す表示ボタンの CSS セレクタ。見出しの後ろ maxDistance 以内で最初に一致するものを押し、読み取り後にもう一度押して伏せ字へ戻す。省略可 |

3. 構造を調べる。値は出力されない。

   `node ~/.claude/skills/chrome-secret-to-keychain/save-secret.ts inspect <登録名>`

   `labelFound` が true で、`afterLabel` が true かつ `matchesPattern` が true の候補があればよい。`from` が値の取り出し元（value / text / attr:名前）。
4. 保存する。成功すると `saved <項目名> (<文字数>)` だけが出る。

   `node ~/.claude/skills/chrome-secret-to-keychain/save-secret.ts save <登録名>`

## Claude が守ること

- 対象タブで `take_snapshot` / `take_screenshot` / `evaluate_script` / `get_network_request` を使わない。値が会話に入る。
- `inspect` 以外で、ページの中身を返すコマンドを実行しない。
- `security find-generic-password ... -w` を実行しない。保存した値を読むのは `run.sh` などの利用側の仕事。
- 登録簿には秘密を書かない。

## 仕組みと限界

- 値の取得も保存も `save-secret.ts` の中で完結し、出力は固定の文言だけにしている。
- `inspect` は 16 文字以上続く英数字を `<redacted:長さ>` に伏せる。16 文字未満の短い秘密は伏せられず、見出しとして出力されうる。
- 保存は `security add-generic-password -w <値>` に引数で渡す。履歴には残らないが、実行中の一瞬だけ同じユーザーの `ps` に見える。
- Keychain の初回の許可ダイアログは GUI でしか押せない。遠隔で使う前に、Mac の前で 1 回保存して「常に許可」を済ませておく。
- ログイン切れや MFA が出たら止まる。再ログインはユーザーが行う。
- 画面が shadow DOM や iframe で作られているページは未対応。
- 見出しの後ろの最初の入力欄が伏せ字のとき、次の入力欄（別のキー）へは進まず失敗する。Algolia のダッシュボードでは Write / Admin のキーが伏せ字で、Search や Analytics のキーは最初から見えているため、この取り違えが実際に起きうる。伏せ字の項目には必ず revealSelector を付ける。

## テスト

`tests/test.sh` が、偽の値だけのローカル HTML と使い捨てのヘッドレス Chrome（ポート 9333）で、`inspect` が値を出さないことと `save` が正しい値を保存することを確認し、テスト用の Keychain 項目を消す。`save-secret.ts` を変えたら必ず実行する。
