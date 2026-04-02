---
description: gh コマンドで PR を作成
---

現在のブランチの変更内容から PR を作成します。

## 手順

1. PR テンプレートに従う
   - リポジトリの `.github/PULL_REQUEST_TEMPLATE.md` または `.github/pull_request_template.md` を確認
   - `~/.dotfiles/pull_request_template.md` もコメント含めて参考にする

2. 過去の PR も参考にする
   - `gh pr list --author=@me --state=all -L 30` で自分の過去 PR を確認

3. `gh pr create` で PR を作成
   - title も body も日本語。敬語は不要。

## gh コマンド例

```sh
# PR テンプレートの確認
gh api repos/{owner}/{repo}/contents/.github/PULL_REQUEST_TEMPLATE.md --jq '.content' | base64 -d

# 過去の自分の PR を確認
gh pr list --author=@me --state=all -L 30

# 特定 PR の body を確認
gh pr view {number} --json body --jq '.body'

# PR 作成
gh pr create --title "タイトル" --body "$(cat <<'EOF'
body の内容
EOF
)"
```
