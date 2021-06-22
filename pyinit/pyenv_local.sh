#!/bin/bash -eu
venvs=$(pyenv versions | peco)
venv0=$(echo "$venvs" | cut -d' ' -f1)
venv1=$(echo "$venvs" | cut -d' ' -f2)
if [[ $venv0 == "*" ]]; then
    venv_name=$venv1
else
    venv_name=$(echo "$venvs" | awk '{ print $1 }')
fi

echo "pyenv local $venv_name"
pyenv local "$venv_name"
