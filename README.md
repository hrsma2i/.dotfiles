# hrsma2i's .dotfiles

## 最低限のインストール

以下で最低限のツール・設定（例：Homebrew や .zshrc 等）がインストールされる。

```sh
curl -sf https://raw.githubusercontent.com/hrsma2i/.dotfiles/master/install.sh | sh -s
```


## 特定のツール・設定のインストール

マシンごとに要不要が異なるツール・設定（例： Node.js や gcloud 等）をインストールするには以下を実行する。

```sh
# 例
~/.dotfiles/node/install.sh
~/.dotfiles/gcloud/install.sh
```
