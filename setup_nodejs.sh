#!/bin/bash -eu

# install volta (Node.js version manager)
# https://zenn.dev/aiueda/articles/7dcecaa05d4f24
# https://docs.volta.sh/guide/getting-started
curl https://get.volta.sh | bash
# version を指定しないと、最新の安定版がインストールされる
volta install node
