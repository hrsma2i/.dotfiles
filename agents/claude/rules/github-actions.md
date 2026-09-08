---
description: .github/workflows 配下のワークフローを書く・改修するときに適用するルール
paths:
  - ".github/workflows/**"
---

- 外部Actionの参照はSHA固定にする（サプライチェーン攻撃対策）。バージョンはコメントとして併記する
  - 例: `uses: step-security/harden-runner@05e31511f85b41b11d1cf0ef85d0992719546e2c # v2.21.0`
- `uses: owner/repo@branch` のようなブランチ参照は暫定措置とする。動作確認が取れ次第 `main` 参照に切り替える（マージ後にブランチが削除されると壊れるため）
- reusable workflow の secrets は呼び出し先側で本当に必要なものだけを宣言し、呼び出し元からの一律継承に頼らない。`workflow_call` の secrets は暗黙継承されないため、呼び出し元・呼び出し先の両方で明示する
- `strategy.matrix` で独立したジョブを並列実行する場合は `fail-fast: false` にする。デフォルトの `fail-fast: true` だと1ジョブの失敗で他の独立したジョブもキャンセルされてしまう
