#!/bin/bash

which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew update

brew tap homebrew/cask || true

# Packages

brew install wget
brew install tree
brew install direnv
brew install jq
brew install pyenv
brew install starship
brew install peco
brew install gibo
# kubernetes
# brew install kubectl
# brew install krew
# brew install kustomize
# brew install k9s
# golang
# brew install golang
# java
# brew install jenv

# c.f., https://qiita.com/b4b4r07/items/3a790fe7e925b4ba14f3
brew install b4b4r07/tap/gomi

# .dmg with homebrew-cask
brew install --cask google-chrome
brew install --cask bettertouchtool
brew install --cask google-japanese-ime
brew install --cask visual-studio-code
brew install --cask notion
brew install --cask slack

# Remove outdated versions
brew cleanup
