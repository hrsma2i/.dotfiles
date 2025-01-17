export PATH="/opt/homebrew/bin:$PATH"

PROJECT_ROOT="$HOME/.dotfiles"

setopt null_glob
for zprofile in "$PROJECT_ROOT"/zsh/zprofile.d/*.zprofile; do
    source "$zprofile"
done
unsetopt null_glob
