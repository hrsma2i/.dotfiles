#!/bin/bash -eu
black_v=$(cat ./pyproject.toml | grep black | cut -d' ' -f3 | tr -d '^')
flake8_v=$(cat ./pyproject.toml | grep flake8 | cut -d' ' -f3 | tr -d '^')
autoflake_v=$(cat ./pyproject.toml | grep autoflake | cut -d' ' -f3 | tr -d '^')

cat <<EOL >.pre-commit-config.yaml
repos:
  - repo: https://github.com/ambv/black
    rev: $black_v
    hooks:
      - id: black
        language_version: python3
  - repo: https://github.com/myint/autoflake
    rev: v$autoflake_v
    hooks:
      - id: autoflake
        args:
          - "--in-place"
          - "--remove-all-unused-imports"
          - "--ignore-init-module-imports"
          - "--remove-unused-variables"
  - repo: https://github.com/pycqa/flake8
    rev: $flake8_v
    hooks:
      - id: flake8
        args:
          - "--max-line-length=88"
          - "--extend-ignore=E203"
EOL

pre-commit install
