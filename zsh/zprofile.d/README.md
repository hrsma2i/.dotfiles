# zprofile.d

各ツール（python, go, gcloud 等）のディレクトリにある部分的な `{tool}/zprofile` を `{tool}/install.sh` によって、ここにコピーし、 `.zprofile` から読み込むようにする。 こうすることで、インストールされたツールに関する設定のみ反映することができる。
