#!/bin/bash -eu

PROJECT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"

"$PROJECT_ROOT"/brew/install_itself.sh

if command -v gcloud >/dev/null 2>&1; then
    echo "'gcloud' has already been installed."
else
    # https://cloud.google.com/sdk/docs/install?hl=ja
    brew install google-cloud-sdk
fi

# brew で一緒にインストールされた python3.11 を参照するようにしないと python not found になる
# shellcheck disable=SC2034
CLOUDSDK_PYTHON=$(brew --prefix)/bin/python3

# initialize gcloud command
# https://cloud.google.com/sdk/docs/initializing?hl=ja
# https://cloud.google.com/sdk/docs/authorizing?hl=ja
# https://medium.com/google-cloud-jp/gcp-%E3%81%A8-oauth2-91476f2b3d7f
# 2回ブラウザで認可を求められる
# Cloud SDK (gcloud, gsutil, bq) をユーザーアカウントで使えるようにする
if gcloud auth list --format="value(account)" | grep -q '.'; then
    echo "You have already logged in to gcloud."
else
    gcloud auth login
fi
# Cloud SDK 以外（dbt や 自作の GCP を操作する Python スクリプト等）をユーザーアカウントで使えるようにする
# https://stackoverflow.com/questions/78109584/gcloud-auth-how-to-check-if-logged-in-in-a-headless-manner
echo "Please wait for 10-20 seconds to check if you have already logged in to gcloud application-default..."
if gcloud auth application-default print-access-token &> /dev/null; then
    echo "You have already logged in to gcloud application-default."
else
    gcloud auth application-default login
fi

cd "$PROJECT_ROOT"
set -x
ln -sfn ../../gcloud/zprofile zsh/zprofile.d/gcloud.zprofile
ln -sfn ../../gcloud/zshrc zsh/zshrc.d/gcloud.zshrc
set +x
