#---------------------------------------------------------------
# compdef, zsh-completions
#---------------------------------------------------------------
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    # to distable the insecure directry warning
    # https://zenn.dev/fujishiro/scraps/ad86d76417909b
    chmod 755 "$(brew --prefix)"/share
fi

autoload -Uz compinit
compinit

#---------------------------------------------------------------
# ENV
#---------------------------------------------------------------
export EDITOR=vim
# Edit command line with my editor
# c.f., https://nuclearsquid.com/writings/edit-long-commands/#:~:text=Now%20all%20you%20need%20to,ZSH%20will%20execute%20your%20command.
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

#---------------------------------------------------------------
# prompt
#---------------------------------------------------------------
eval "$(starship init zsh)"

#---------------------------------------------------------------
# ls & grep aliases
#---------------------------------------------------------------
alias ls="ls -G"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias pyinit="make -f "$HOME"/.dotfiles/pyinit/Makefile "

#---------------------------------------------------------------
# git aliases
#---------------------------------------------------------------
alias br="git branch"
alias co="git checkout"
alias cob="git checkout -b"
alias st="git status"
alias add="git add"
alias cm="git commit"
alias amend="git commit --amend"
alias push="git push"
alias pull="git pull"
alias merge="git merge"
alias reset="git reset"

#---------------------------------------------------------------
# history
#---------------------------------------------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=1000000

# share .zshhistory
setopt inc_append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups

function peco-select-history() {
    local tac
    if which tac >/dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 |
        eval $tac |
        peco --query "$LBUFFER" |
        sed 's/\\n/\n/g')
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

#---------------------------------------------------------------
# pyenv
#---------------------------------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
eval "$(pyenv init -)"

#---------------------------------------------------------------
# Poetry
#---------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
if [ -f $HOME/.poetry/env ]; then
    source $HOME/.poetry/env
fi

#---------------------------------------------------------------
# load local .zshrc
#---------------------------------------------------------------

[ -e ~/.local.zshrc ] && source ~/.local.zshrc

#---------------------------------------------------------------
# Go
#---------------------------------------------------------------
which go >/dev/null && export PATH="$(go env GOPATH)/bin:$PATH"

#---------------------------------------------------------------
# k8s
#---------------------------------------------------------------
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# export KUBECTX_INGORE_FZF=1
alias kc=kubectl
alias kcx='kubectx | peco | xargs kubectx'

#---------------------------------------------------------------
# Java
#---------------------------------------------------------------
export PATH="$HOME/.jenv/bin:$PATH"
if command -v jenv >/dev/null; then
    eval "$(jenv init -)"
fi
export CPPFLAGS="-I/usr/local/opt/openjdk/include"
export PATH="/usr/local/opt/maven@3.3/bin:$PATH"

#---------------------------------------------------------------
# gcloud
#---------------------------------------------------------------
export CLOUDSDK_PYTHON=$(which python)
function gx-complete() {
    _values $(gcloud projects list | awk '{print $1}')
}
function gx() {
    project="$1"
    if [ -z "$project" ]; then
        line=$(gcloud projects list | peco)
        project=$(echo "${line}" | awk '{print $1}')
    else
        line=$(gcloud projects list | grep "$project")
    fi
    echo "gcloud config set project \"${project}\""
    gcloud config set project "${project}"
}
compdef gx-complete gx

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hiroshi.matsui/Downloads/google-cloud-sdk/path.zsh.inc' ]; then
    . '/Users/hiroshi.matsui/Downloads/google-cloud-sdk/path.zsh.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hiroshi.matsui/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then
    . '/Users/hiroshi.matsui/Downloads/google-cloud-sdk/completion.zsh.inc'
fi

#---------------------------------------------------------------
# Volta (node version manager)
#---------------------------------------------------------------
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
