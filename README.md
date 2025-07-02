# dotfiles

個人の開発環境をセットアップするためのツール

## ユースケース

- 最低限のツール・設定（Homebrew や .zshrc 等）をインストールできる
- マシンごとに要不要が異なるツール・設定（Node.js や gcloud 等）を個別にインストールできる
- 特定のツール（Python や Go 等）を用いたプロジェクトのリポジトリの初期化ができる

## 手順書

### 最低限のインストール

以下で最低限のツール・設定（例：Homebrew や .zshrc 等）がインストールされる。

```sh
curl -sf https://raw.githubusercontent.com/hrsma2i/.dotfiles/master/install.sh | sh -s
```

.zprofile 等を反映させるため

```sh
exec $SHELL -l
```

### 特定のツール・設定のインストール

マシンごとに要不要が異なるツール・設定（例： Node.js や gcloud 等）をインストールするには以下を実行する。

```sh
# 例
~/.dotfiles/node/install.sh
~/.dotfiles/gcloud/install.sh
```

.zprofile 等を反映させるため

```sh
exec $SHELL -l
```

### プロジェクトの初期化

特定のツール（例： Python や Go 等）を用いたプロジェクトのリポジトリの初期化をするには以下を実行する。

```sh
~/.dotfiles/python/init.sh $PROJECT_NAME
```

なお、 必要なツール（Python や gibo, pre-commit） がなければ init.sh 内でインストールされるので、いきなり init.sh してもOK。

## 技術スタック

- Bash スクリプト
- Homebrew
- zsh
- 各種開発ツール（Node.js、Python、gcloud等）

## アーキテクチャ

各ツールが独立したディレクトリに配置され、標準化されたインストールスクリプトを持つモジュラー構造

- `shared/` - 共通のインストール関数
- `zsh/` - シェル設定とツール固有設定の管理  
- `各ツール/` - install.sh と init.sh（オプション）を含む
- `agents/` - AI エージェント向け行動ルール
