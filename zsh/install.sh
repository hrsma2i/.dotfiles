#!/bin/bash -eu
DOTFILES="$HOME/.dotfiles"
set -x
ln -sfn "$DOTFILES"/zsh/zshrc "$HOME"/.zshrc
ln -sfn "$DOTFILES"/zsh/zprofile "$HOME"/.zprofile
set +x
