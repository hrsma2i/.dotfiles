#!/bin/bash -eu

if command -v brew >/dev/null 2>&1; then
    echo "'brew' has already been installed."
else
    # https://brew.sh/ja/
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
