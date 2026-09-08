---
name: gha-ai-workflow
description: TRIGGER when GitHub ActionsからAIエージェント(claude-code-action等)を呼び出すワークフローを新規作成・変更するとき。DO NOT TRIGGER when AIエージェントを含まない通常のCI/CDワークフローを扱うとき。
---

GHAから自動実行されるAIエージェントは、プロンプトインジェクションやモデル更新に起因する意図しない挙動が起きうる前提でガードレールを設計する。

## チェックリスト

1. `allowed-tools` を必要最小限（読み取り系中心）に絞って明示する
   - 例: `--allowed-tools "Read,Grep,Glob,WebFetch"`
2. IAMロールをセッション単位の inline-session-policy で最小権限に絞る
   - 例: Bedrock呼び出しなら `bedrock:InvokeModel` 等、必要なアクション・リソースARNのみ許可
3. Harden Runner の `egress-policy: block` + `allowed-endpoints` で通信先をホワイトリスト化する
   - 呼び出すAPI（GitHub API、Bedrock runtimeエンドポイント等）のみを列挙する
