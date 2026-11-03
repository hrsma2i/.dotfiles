---
name: md
description: "TRIGGER when: 直前の返答（箇条書きや表など）を「md で」「mdにして」確認したいと頼まれた。DO NOT TRIGGER when: 既存の Markdown ファイルを確認したいとき。"
---

直前に自分（Claude）が返答として出力した内容（箇条書き・表など）を、そのまま Markdown ファイルに書き起こし、`code <path>` で開く。

1. 保存先はスクラッチパッドディレクトリ。
2. 必ず `code <path>` コマンドで開く。プレビューでは開かない。
