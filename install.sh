#!/bin/bash

DOTFILES="$HOME/.dotfiles"

[[ -e "$DOTFILES" ]] || git clone https://github.com/hrsma2i/.dotfiles.git "$DOTFILES"
pushd "$DOTFILES" || exit

# brew/install_itself.sh
zsh/install.sh
mise/install.sh
git/install.sh

# symlinks
ln -sfn ~/.dotfiles/starship.toml ~/.config/starship.toml

# マシンごとに要不要が異なるツールをコメントアウトで選ぶ方式は廃止した。
# 現在は <ツール>/install.sh を個別に実行する（README 参照）。
# AWS は install.sh を用意するほど使わないため、手順メモとして残している。
# AWS
# curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
# sudo installer -pkg /tmp/AWSCLIV2.pkg -target / # /usr/local/bin/aws

popd || exit
