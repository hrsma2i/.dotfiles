#!/bin/bash -eu

project_root="$(cd "$(dirname "$0")"/.. && pwd)"

"$project_root"/brew/install_itself.sh

# shell
# https://zenn.dev/sprout2000/articles/bd1fac2f3f83bc
brew install zsh-completions
# Preinstalled git in MacOS is called `Apple Git`, which is not useful.
# `brew git` has zsh completions.
brew install starship
brew install peco

# others
brew install wget
brew install tree
brew install jq
brew install docker
# c.f., https://qiita.com/b4b4r07/items/3a790fe7e925b4ba14f3
brew install b4b4r07/tap/gomi

# GUI
brew install google-chrome
brew install bettertouchtool
brew install google-japanese-ime
brew install visual-studio-code
brew install notion
brew install slack
brew install docker

# Remove outdated versions
brew cleanup
