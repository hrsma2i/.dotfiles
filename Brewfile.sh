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
brew install nodenv
brew install starship
brew install peco
brew install gibo
brew install docker

# Kubernetes
# brew install kubectl
# brew install krew
# brew install kubectx
# brew install kustomize
# brew install k9s

# Terraform
# brew install tfenv
# tfenv install $TF_VERSION
# tfenv use $TF_VERSION

# Golang
brew install golang
# java
# brew install jenv
brew install pre-commit

# c.f., https://qiita.com/b4b4r07/items/3a790fe7e925b4ba14f3
brew install b4b4r07/tap/gomi

# .dmg with homebrew-cask
brew install --cask google-chrome
brew install --cask bettertouchtool
brew install --cask google-japanese-ime
brew install --cask visual-studio-code
brew install --cask notion
brew install --cask slack
brew install --cask docker

# Remove outdated versions
brew cleanup
