---
name: line-bot
description: "TRIGGER when: LINE Bot（Messaging API）の作成・Webhook 実装・コマンド設計・ヘルプや通知メッセージの作成・動作確認をするとき（GAS 上のものを含む）。DO NOT TRIGGER when: LINE と無関係な GAS や、LINE Notify など別サービスを扱うとき。"
---

自作 LINE Bot（立替精算くん, 買い時お知らせ君）で得た知見。GAS 側の共通事項は google-apps-script skill を参照する。

## Bot の作成

- LINE Developers コンソールから Messaging API のチャネルを直接作れない。LINE 公式アカウント（entry.line.biz、未認証・無料のコミュニケーションプラン）を作り、Official Account Manager で「Messaging API を利用する」を有効にし、プロバイダーを選ぶとチャネルができる。
- 有効化は取り消せない。1 つのチャネルに登録できる Webhook URL は 1 つなので、別アプリのチャネルを使い回さない。dev / prod を分けるなら Bot（チャネル）を 2 つ作り、同じプロバイダーに置く（ユーザー ID が共通になる）。
- LINE Notify は 2025 年 3 月に終了している。通知だけでも Messaging API を使う。
- Messaging API 設定で、応答メッセージとあいさつメッセージをオフにする（オンだと定型の自動返信が混ざる）。チャットはオフ。
- チャネルアクセストークン（長期）を発行する。自分のユーザー ID はチャネル基本設定の下部にある。
- Bot 名（アカウント名）は勝手に決めない。ユーザーと決めた名前を確認してから使う。過去に違う名前を作ってデプロイし、直す羽目になった。命名は「〜くん」「〜お知らせ君」のように、既存の Bot と揃える。
- 作成作業は operate-chrome / Claude in Chrome で進めてよいが、ログイン、規約への同意、アカウント作成の最終ボタンはユーザーが行う。トークンは画面から会話に出さず、スクリプトプロパティへ直接つなぐ。設定変更（トグルのオフなど）は変更前に内容を見せて許可を得る。

## 秘密の値

- LINE_CHANNEL_TOKEN（チャネルアクセストークン）、WEBHOOK_SECRET（`openssl rand -hex 16` で作る）、LINE_GROUP_ID などをスクリプトプロパティに置く。キー名だけ事前に用意し、値はユーザーが入力する（google-apps-script skill 参照）。

## Webhook（GAS の doPost）

- GAS はリクエストヘッダを読めないので、X-Line-Signature の署名検証はできない。代わりに、推測できないデプロイ URL、URL の `?secret=`、送信元の userId / groupId の照合を重ねる。
- Webhook URL は `<デプロイ URL>?secret=<WEBHOOK_SECRET>`。デプロイを更新しても URL が変わらないようにする（clasp redeploy）。
- LINE コンソールの「検証」は GAS が 302 を返すため失敗表示になるが、実際のメッセージは届く。
- 常に 200 を返す（ContentService で `ok`）。処理が重くて遅れると LINE が再送するので、webhookEventId を CacheService に 6 時間入れて重複排除する。
- 複数イベントが 1 リクエストに入る。`events[0]` だけでなく全部ループする（立替精算くんは先頭だけ処理していた）。
- イベントの種類は message / join / unsend / postback / follow など。扱わないイベントとテキスト以外のメッセージ（スタンプ、画像）には何も返さない。毎回エラーを返すとうるさい。
- join（グループ参加）では使い方を返す。unsend（送信取消）は、記録の削除に使える（立替精算くんは取消で立替ログを削除する）。
- TypeScript では event / source / message の型と型ガード（`isMessageEvent` など）を定義し、LINE API 呼び出しを 1 クラスにまとめる（https://github.com/hrsma2i/tatekae-seisan-kun/blob/main/src/external/line.ts を参考）。

## 返信と通知

- reply（replyToken、無料・無制限）を優先し、push は定期通知だけに使う。無料プランの push は月 200 通程度（実装時に最新のプランを確認する）。1 日 1 通にまとめ、通知がなければ送らない。
- エラー時は、replyToken があれば reply、なければ push で「エラーが起きました」と原因を伝え、`console.error` でログにも残す。ユーザーに見えるエラーは「何が起きたか」と「次にすること」を書く。
- 外部連携の認証切れ（Cookie 期限切れなど）は、最初のリクエストで検知して処理を中断し、更新方法を LINE で知らせる。後続の大量リクエストを送り続けない。
- 返信テキストは 5000 文字まで。メッセージは 1 回の reply で最大 5 件。

## コマンド設計

- 1 行目がコマンド（または対象名）、2 行目以降が引数、の改行区切りにする。スペース区切りは、引数に空白を含む値で壊れる。グループでは @メンションの位置情報（mention.mentionees の index / length）から名前を取れる。
- クイックリプライの label は 20 文字まで。displayText に完全な名前を入れる。postback data は 300 文字まで。
- 提案を承認 / 却下させるときも、提案の値を postback data に入れる（承認 / 却下のクイックリプライ）。

## ヘルプ（使い方）

- Flex Message の bubble で、先頭に自己紹介（「〇〇くんです！使い方を説明しますね。以下の青文字のメッセージを送信すると、その操作ができます。」）を置く。
- コマンドごとに、区切り線、太字のタイトル、青（#0F68DA）の斜体でコマンド、通常文字で説明と例、を並べる（https://github.com/hrsma2i/tatekae-seisan-kun/blob/main/src/presentation/handlers/UsageHandler.ts を参考）。
- 引数は `{商品名}` のようなプレースホルダで表し、各引数に指定できる書式を例で示す。
- コマンドなしで対象名だけ送られたときや、解釈できない入力のときもヘルプを返す。
- 文言は、変更後の返信例を先に見せて承認を得てから反映・デプロイする。

## グループと個人

- 初回は LINE_GROUP_ID が分からない。Bot をグループに招待してメッセージを送り、Cloud Logging（GAS を標準 GCP プロジェクトに紐付ける）で未登録の groupId のログを見て、スクリプトプロパティに設定する。
- ユーザー名やグループ名は profile API / group summary API で取れる。

## 動作確認

- 実機の LINE で確認する。ヘルプの Flex の見た目、グループでの返信、クイックリプライの選択肢、個人トークの案内は、自動テストでは確かめられない。
- 動作確認用のコマンド（replyText / replyButtonList / push など）を載せたテスト用の doPost を、dev の Bot に置く方法もある。
- 動作確認のたびのデプロイは、ユーザーの許可の範囲内でだけ行う（google-apps-script skill のデプロイの節）。
- 選択肢が複数出るケースを確認したいときは、候補が複数ある対象があるかをデータから調べて、実機で送る例文を示す。
