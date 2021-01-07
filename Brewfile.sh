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
# kubernetes
# brew install kubectl
# brew install krew
# brew install kustomize
# brew install k9s
# golang
# brew install golang
# java
# brew install jenv

# .dmg with homebrew-cask
brew install --cask google-chrome
brew install --cask bettertouchtool
brew install --cask google-japanese-ime
brew install --cask visual-studio-code
brew install --cask notion
brew install --cask slack

# Remove outdated versions
brew cleanup
