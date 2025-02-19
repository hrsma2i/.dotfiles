#!/bin/bash -eu

install_if_not_exists() {
    local cmd="$1"
    local install_cmd="$2"

    if command -v "$cmd" &>/dev/null; then
        echo "'$cmd' has already been installed."
    else
        echo "'$cmd' has not been installed yet. Installing..."
        eval "$install_cmd"
    fi
}
