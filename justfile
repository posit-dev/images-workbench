#!/usr/bin/env just --justfile

setup:
  pre-commit --version || (echo "pre-commit not found, install with: uv tool install pre-commit" && exit 1)
  pre-commit install --install-hooks

install-bakery *OPTS:
  #!/bin/bash
  # TODO: Update this after package is published somewhere
  uv tool install {{OPTS}} 'git+ssh://git@github.com/posit-dev/images-shared.git@main#egg=posit-bakery&subdirectory=posit-bakery'

install-goss:
  #!/bin/bash
  mkdir -p tools
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o {{justfile_directory()}}/tools/goss
  chmod +rx {{justfile_directory()}}/tools/goss
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/dgoss -o {{justfile_directory()}}/tools/dgoss
  chmod +rx {{justfile_directory()}}/tools/dgoss

init: install-bakery install-goss
