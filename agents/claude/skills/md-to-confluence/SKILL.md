---
name: md-to-confluence
description: md ファイルを Confluence に転記するときに呼ぶ
---

md ファイルを Confluence に転記する際のルール:

- ページ作成時、親ページの URL から space_key を推測せず、page_id から `confluence_get_page` で space_key を確認する

- 冒頭に目次マクロを挿入する
- タイトル（`#`）は見出しではなく、 Confluence ページのタイトルに設定する。
- `##` は見出し 1、`###` は見出し 2 に変換する
- インラインコード（`` `...` ``）はコード装飾にする
- コードブロック（` ```...``` ` ）はコードスニペットマクロを用いる
