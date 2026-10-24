---
name: google-apps-script
description: "TRIGGER when: Google Apps Script (GAS) のプロジェクトを新規作成・実装・テスト・デプロイするとき（TypeScript / appsscript.json / clasp を扱う）。DO NOT TRIGGER when: GAS と無関係な Node.js / Cloud Functions の開発のとき。"
---

## プロジェクトの作り方

- 新規作成は `~/.dotfiles/clasp/init.sh <project名>` を参考にする（`clasp create` + `@types/google-apps-script` + `.gitignore` に `.clasp.json`）。
- `clasp create` / `clasp create-script` は `appsscript.json` を上書きする（timeZone が America/New_York になり、oauthScopes / webapp が消える）。実行前にバックアップし、実行後に復元して `.clasp.json` の `rootDir` も直す。
- `appsscript.json` は必ず `"timeZone": "Asia/Tokyo"`, `"runtimeVersion": "V8"`, `"exceptionLogging": "STACKDRIVER"` を入れる。
- 使う API に応じて `oauthScopes` を明示する（外部通信は `script.external_request`、Gmail は `gmail.modify` 等）。
- 複数 GAS を 1 リポジトリで管理するなら 1 プロジェクト 1 サブディレクトリ（それぞれ `.clasp.json` を持つ）。
- プロジェクト名・GCP プロジェクト名に `gas` は付けない（用途名だけにする）。dev / prd を分ける必要がなければ 1 プロジェクトにする。

## 言語・構成

- 規模によらず TypeScript で書く。`.gs` は書かない。
- `tsc` で `dist/` に出力して `appsscript.json` を `dist/` にコピーし、`.clasp.json` の `rootDir` を `dist` にする（https://github.com/hrsma2i/ootd-gas/blob/main/form-to-issue/package.json の `build` / `push` スクリプトを参考）。バンドルが要るなら rollup（`--no-treeshake`）。
- 規模が大きくなったら https://github.com/hrsma2i/tatekae-seisan-kun のように `domain / application / infrastructure / presentation / external(GAS)` の層に分ける。純粋関数と GAS API 呼び出しは別関数に分ける。
- `.claspignore` に `test/**` を入れてテストを push しない。

## 設定・秘密情報

- 秘密情報はコードに置かず `PropertiesService.getScriptProperties()` から読む。未設定は `throw new Error('スクリプトプロパティ X が未設定です')` で気付けるようにし、任意項目用に例外にしない読み取り関数も用意する。
- スクリプトプロパティは、必要なキーを洗い出し、Claude in Chrome で Apps Script の「プロジェクトの設定」を開いて、キー名だけを入力した行を事前に追加しておく。値は空のまま保存せず、入力欄を用意したところで止め、ユーザーに値だけを入力して保存してもらう。
- 値は自分で入力せず、読み取って会話に出さない（診断出力も ID など最小限にマスクする）。
- 「プロジェクトの設定」ページでは、chrome-devtools MCP の `take_snapshot` など、ページ全体を出力する操作を使わない（既存プロパティの値が全部出力される）。スクリプトプロパティの操作は Claude in Chrome で行う。
- `.clasprc.json` / `.clasp.json` / `.env.secret` は git 管理外。

## Web アプリ（Webhook: LINE 等）

- `doPost(e)` で受ける。`appsscript.json` の `webapp` は `executeAs: USER_DEPLOYING`, `access: ANYONE_ANONYMOUS`。
- GAS はリクエストヘッダを読めないので、署名検証はできない。推測できない URL + `?secret=` クエリ + body の照合で代替する。
- Webhook の再配送があるため、イベント ID を `CacheService` に入れて重複排除する。
- URL を変えないためデプロイは「更新」（後述）。新規デプロイすると URL が変わる。
- LINE Bot の場合は line-bot skill を参照する。

## ログ（Cloud Logging）

- 既定の GCP プロジェクトではログを読めない。標準 GCP プロジェクトに紐付ける（OAuth 同意画面の設定 → 自分をテストユーザーに追加 → 再承認。「審査プロセスを完了していません」エラーはテストユーザー未追加が原因）。
- 紐付け後は `gcloud logging read 'resource.type="app_script_function"' --project=<id> --format=json` で読める。LINE の groupId なども `console.log` してここから取る。
- 削除した GCP プロジェクトは 30 日間 ID が使えない。作る前に名前を確認する。

## テスト

- jest + ts-jest で単体テストし、`jest-mock-extended` で GAS オブジェクトをモックする（https://github.com/hrsma2i/tatekae-seisan-kun/blob/main/package.json 参考）。GAS 固有の呼び出しは関数内に閉じ込め、読み込み時に評価しない。
- 外部 API を叩く長い処理は `UrlFetchApp.fetchAll` を並列数を増やしながらリトライするラッパー（https://github.com/hrsma2i/tatekae-seisan-kun/blob/main/src/external/GAS/scalingRetryFetchAll.ts）で包む。認証切れなど再試行しても無駄なエラーは `getAbortError` 的な仕組みで即中断し、ユーザーに通知する。

## デプロイ（clasp 3.x）

- コマンド: `npm run build` → `clasp push --force` → `clasp create-version` → `clasp redeploy <deploymentId>`。既存デプロイを更新するので Webhook URL は変わらない。
- deploymentId は `clasp list-deployments` から `@HEAD` 以外の `AKfycb...` を取る。`package.json` の `scripts.deploy` に書き、README に手順を載せる（https://github.com/hrsma2i/supplies-restocker/blob/main/gas/package.json 参考）。
- dev / prod を分ける場合は `.clasp-dev.json` / `.clasp-prod.json` を `.clasp.json` にコピーしてから push する（https://github.com/hrsma2i/tatekae-seisan-kun/blob/main/package.json の `setup:clasp` / `push:test`）。
- 初回の `clasp push` やデプロイは、自動モードだと権限分類器に拒否されることがある。回避せず、ユーザーに `! cd gas && clasp push --force` の形で実行してもらう。
- 新規デプロイ（Web アプリの種類設定や初回承認）は GUI 操作が必要。初回承認は、エディタで関数（例: `todayJst`）を 1 回実行して許可する。
- 本番デプロイは、ユーザーの許可が出るまで勝手にしない。返信文などユーザーに見える変更は、先に例を示して承認を得る。
- `dprint fmt` / `eslint --fix` は無関係なファイルまで大量に整形するので、実行後は `git status` を確認し、対象外は `git checkout --` で戻す。

## ブラウザ操作が要る作業

- スクリプトプロパティのキー名の事前入力、デプロイ画面、GCP コンソールは Chrome 操作になる。パスワードや秘密値の入力はしない（キー名だけ入れた欄を用意し、値はユーザーに入力してもらう）。スクリプトプロパティの画面は Claude in Chrome で操作する。

## 注意

- macOS では `sed -i` が黙って失敗することがある。編集は Edit か python で行い、編集とデプロイを `&&` で連結しない（失敗後にデプロイが走る）。
- 兄弟リポジトリを grep するときは `.env.secret` を巻き込んで秘密値を出力しないよう、対象ファイルを絞る。
