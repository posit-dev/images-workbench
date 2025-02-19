#!/usr/bin/env just --justfile

GITHUB_TOKEN := `gh auth token`

install-bakery *OPTS:
  #!/bin/bash
  # TODO: Update this after package is published somewhere
  pipx install {{OPTS}} 'git+ssh://git@github.com/posit-dev/images-shared.git@main#egg=posit-bakery&subdirectory=posit-bakery'

install-goss:
  #!/bin/bash
  mkdir -p tools
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o {{justfile_directory()}}/tools/goss
  chmod +rx {{justfile_directory()}}/tools/goss
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/dgoss -o {{justfile_directory()}}/tools/dgoss
  chmod +rx {{justfile_directory()}}/tools/dgoss

init: install-bakery install-goss

download-pti:
  mkdir -p {{justfile_directory()}}/tools
  curl -sSL \
      -H 'Accept: application/octet-stream' \
      -H "Authorization: Bearer {{GITHUB_TOKEN}}" \
      https://api.github.com/repos/posit-dev/pti/releases/assets/220659328 \
      -o {{justfile_directory()}}/tools/pti
