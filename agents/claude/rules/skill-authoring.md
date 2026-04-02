---
description: SKILL.md を編集するときに適用するルール
paths:
  - "agents/claude/skills/**/SKILL.md"
---

frontmatter パラメータの一覧は公式ドキュメントを参照: https://code.claude.com/docs/ja/skills

## 注意

- frontmatter は valid な YAML として書く。編集後は `mcp__ide__getDiagnostics` でエラーがないか確認する
  - 例: `[...]` を含む文字列はクォートしないと配列と解釈される
    - NG: `argument-hint: [issue-number]`
    - OK: `argument-hint: "[issue-number]"`
