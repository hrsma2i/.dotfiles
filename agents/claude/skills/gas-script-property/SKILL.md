---
name: gas-script-property
description: >-
  TRIGGER when: Keychain に保存済みの秘密を、Claude に見せずに Apps Script のスクリプトプロパティへ入れたい。
  DO NOT TRIGGER when: 秘密がまだ画面にあるだけ（chrome-secret-to-keychain で先に Keychain へ）; or 秘密ではない値（手で入力できる）。
---

# Keychain の値を Apps Script のスクリプトプロパティに入れる

値は `set-script-property.ts` の中で完結し、出力は固定の文言だけ。

## 使い方

1. 専用 Chrome（9222）で、対象プロジェクトの「プロジェクトの設定」だけを開いておく（ログインはユーザー）。
2. 画面の構造を確かめる（値は出ない）。ボタンや入力欄が想定と違えば、スクリプトを直す。

   `node ~/.claude/skills/gas-script-property/set-script-property.ts inspect`
3. 入れる。成功すると `saved <プロパティ名> (<文字数>)` だけが出る。

   `node ~/.claude/skills/gas-script-property/set-script-property.ts set <プロパティ名> <Keychain の項目名>`

   - 既存のプロパティ名は失敗する。置き換えるときだけ `--overwrite`。
   - 保存ボタンを人が押すなら `--no-save`（入力欄を埋めて止まる）。

## Claude が守ること

- 対象タブで `take_snapshot` / `take_screenshot` / `evaluate_script` を使わない。既存プロパティの値が全部会話に入る。
- `security find-generic-password ... -w` を実行しない。

## 限界

- 「名前, 値」の 2 欄ずつの並びを前提にしている。Apps Script の画面が変わったら `inspect` で確かめて直す。
- 入力後は、ページ側での保存ができたかを `get` 系で読み戻さない（値が出る）。保存後の確認は、プロパティ名の行が増えたことをユーザーが見る。

## テスト

`tests/test.sh`（偽のページと偽の値だけ。使い捨てのヘッドレス Chrome を使う）。`set-script-property.ts` を変えたら必ず実行する。
