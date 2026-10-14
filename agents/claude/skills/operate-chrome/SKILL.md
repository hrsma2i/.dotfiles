---
name: operate-chrome
description: >-
  TRIGGER when: API が公開されていない or 有料で、かつ認証が必要なサイトの操作・スクレイピング・データ取得を頼まれた;
  or ログイン済みブラウザの画面から情報を取りたい。
  DO NOT TRIGGER when: 公式 API / MCP / CLI で足りるとき; or 認証不要の公開ページ（WebFetch で足りる）。
---

認証が必要なサイトを、別プロセスで立ち上げた専用 Chrome（CDP 経由）で操作・スクレイピングする。
Claude in Chrome 拡張は画面遷移とスクリーンショットを繰り返すため遅い。
そこで Network 通信と HTML/JS を Claude 自身に解析させ、ページ内で JS（`fetch` 等）を直接実行することで、画面遷移なしに高速に取得・操作する。

## 準備（初回のみ）

Chrome 136 以降は通常のメインプロファイルでリモートデバッグを開けないため、専用プロファイルを使う。

1. 専用プロファイルで CDP ポートを開いた Chrome を別プロセスで起動する。
   `nohup "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 --user-data-dir="$HOME/.chrome-debug-profile" > /tmp/chrome-debug.log 2>&1 &`
   - 起動済みか: `curl -s http://127.0.0.1:9222/json/version`
2. `chrome-devtools` MCP が未登録なら登録する（セッション再起動が必要）。
   `claude mcp add --transport stdio chrome-devtools -- npx -y chrome-devtools-mcp@latest --browserUrl=http://127.0.0.1:9222`
3. 起動したウインドウで、ユーザー自身の手で対象サイトにログインしてもらう。
   - Claude からパスワードや MFA コードを入力しない。ID/PW・Cookie・トークンをチャットに貼らせない。
   - Cookie は専用プロファイルに保持されるため、次回以降は再ログイン不要（期限切れ時のみ再依頼）。
4. デバッグ用 Chrome 自体は kill しない（ログイン状態を失う）。

## 手順

1. 目的（取得したいデータ / 行いたい操作）と対象サイトを確認する。読み取りか書き込み（送信・購入・削除等）かも切り分ける。
2. `mcp__chrome-devtools__new_page` で対象ページを開く。ログイン画面に飛ばされたらユーザーにログインを依頼して待つ。
3. 内部 API を探す（最優先）。
   - `list_network_requests` / `get_network_request` で、画面操作時に飛ぶ XHR / fetch（JSON を返すもの）を特定する。
   - URL・メソッド・必要なヘッダ（CSRF トークン等）・ペイロード・ページング方法を把握する。
   - 必要なら JS バンドルや HTML を読んでエンドポイントやパラメータの意味を解析する。
4. `evaluate_script` でページ内から `fetch(url, { credentials: "include" })` を実行してデータを取る。
   - ページのオリジン上で動くため、Cookie・CSRF 等の認証はログイン済みセッションがそのまま使われる。
   - 画面遷移しないので高速。複数ページ分のループやページングもスクリプト内で完結させる。
   - CSRF トークンなどはページの DOM / `meta` / Cookie からスクリプト内で読み取って使い、出力には含めない。
5. 内部 API が見つからない・使えない場合のみ DOM から取得する。
   - `evaluate_script` で `document.querySelectorAll` 等を実行し、必要な部分だけ JSON で返す。
   - セレクタは `#root` からの長い祖先パスを避け、ページ内で一意な固有クラスを起点に短く書く。
   - モバイル表示でしか出ない情報は `emulate` で viewport / UA を切り替えてから再読み込みして調べる。
6. 結果は作業ディレクトリ内の一時ファイル（CSV / JSON）に保存し、要約をユーザーに報告する。
   - `evaluate_script` の `filePath` で保存すると文字列は JSON エンコードされるので、必要なら `python3 -c "import json; ..."` 等でデコードする。
   - 取得物に個人情報・認証情報が含まれていないか確認し、不要な項目は落とす。
7. 繰り返し使う取得処理は、`evaluate_script` に渡したスクリプトをファイルに残して再利用できるようにする（ユーザーが希望した場合）。

## 守ること

- 利用規約・robots.txt に反するアクセスや、アカウント停止リスクが高い大量アクセスはしない。リクエスト間隔を空け（目安 1 秒以上）、並列化しない。
- まず読み取り系のみ実行する。送信・購入・削除など副作用のある操作は、実行内容を示してユーザーの確認を得てから行う。
- 取得した Cookie / トークン / セッション情報を出力・ファイル保存・commit しない。
- 自分のアカウントのデータ取得・操作に限る。他人のアカウントや、認可されていないデータには使わない。

## トラブルシュート

- `mcp__chrome-devtools__*` が 1 分以上応答しない: MCP サーバー側の接続が壊れている可能性が高い。
  1. `TaskStop` で固まったタスクを止める。
  2. `pgrep -fl "chrome-devtools-mcp"` で見つかったプロセスを `kill -9` する（Chrome 本体は殺さない）。
  3. ユーザーに Claude Code のセッション再起動を依頼する。
- `curl http://127.0.0.1:9222/json/version` が失敗する: Chrome が起動していない、または別プロセスがポートを使用中。準備 1 をやり直す。
- fetch が 401 / 403: セッション切れ、または CSRF トークン・必須ヘッダ不足。ページ自身が送るリクエストと見比べる。
