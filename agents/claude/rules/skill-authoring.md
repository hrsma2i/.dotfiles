---
description: SKILL.md を編集するときに適用するルール
paths:
  - "**/SKILL.md"
---

SKILL.md を編集する前に https://code.claude.com/docs/ja/skills を取得して仕様を確認し、frontmatter パラメータと文字列置換を可能な限り活用する。

## description

- TRIGGER when / DO NOT TRIGGER when で具体的なトリガー条件を明示する
- 複数条件がある場合は論理関係（and / or）を明記する
- 250文字以内に収める（超過分は切り捨てられる）

## 本文

- 手順は本質的かつ簡潔に書く。見出しの行は短くする
- 詳細な手順やルールは、独立した節にせず、対応するステップの子として箇条書きにする

## 注意

- frontmatter は valid な YAML として書く。編集後は `mcp__ide__getDiagnostics` でエラーがないか確認する
  - 例: `[...]` を含む文字列はクォートしないと配列と解釈される
    - NG: `argument-hint: [issue-number]`
    - OK: `argument-hint: "[issue-number]"`
