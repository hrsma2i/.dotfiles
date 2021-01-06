#---------------------------------------------------------------
# ENV
#---------------------------------------------------------------
export EDITOR=vim


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
# pyenv
#---------------------------------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi


#---------------------------------------------------------------
# Poetry
#---------------------------------------------------------------
if [ -f $HOME/.poetry/env ];then
  source $HOME/.poetry/env
fi


#---------------------------------------------------------------
# load local .zshrc
#---------------------------------------------------------------

[ -n ~/.local.zshrc ] && source ~/.local.zshrc


#---------------------------------------------------------------
# go-swagger
#---------------------------------------------------------------
alias swagger="docker run --rm -it -e GOPATH=$GOPATH:/go -v $HOME:$HOME -w $(pwd) quay.io/goswagger/swagger"


#---------------------------------------------------------------
# k8s
#---------------------------------------------------------------
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export KUBECTX_INGORE_FZF=1
alias kc=kubectl
alias kcx=kubectx
