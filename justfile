#!/usr/bin/env just --justfile

BAKERY_VERSION := "0.2.0.dev0"

init-venv:
  #!/bin/bash
  set -ex
  rm -rf .venv
  python3 -m venv .venv

install-bakery:
  #!/bin/bash
  # TODO: Update this after package is published somewhere
  {{justfile_directory()}}/.venv/bin/pip3 install https://saipittwood.blob.core.windows.net/packages/posit_bakery-{{ BAKERY_VERSION }}-py3-none-any.whl

install-goss:
  #!/bin/bash
  mkdir -p tools
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o {{justfile_directory()}}/tools/goss
  chmod +rx {{justfile_directory()}}/tools/goss
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/dgoss -o {{justfile_directory()}}/tools/dgoss
  chmod +rx {{justfile_directory()}}/tools/dgoss

init: init-venv install-bakery install-goss

new product base_image="posit/base":
  {{ justfile_directory() }}/.venv/bin/bakery new "{{product}}" --context {{ justfile_directory() }} --image-base {{base_image}} --image-type "product"

alias generate := render
render product version r_version python_version *OPTS:
  {{ justfile_directory() }}/.venv/bin/bakery render "{{product}}" "{{version}}" \
    --value r_version={{r_version}} \
    --value python_version={{python_version}} {{OPTS}}

alias bake := build
build *OPTS:
  {{ justfile_directory() }}/.venv/bin/bakery build --context {{ justfile_directory() }} {{OPTS}}

alias dgoss := test
test *OPTS:
  {{ justfile_directory() }}/.venv/bin/bakery dgoss --context {{ justfile_directory() }} {{OPTS}}
