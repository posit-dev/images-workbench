#!/usr/bin/env just --justfile


init:
  #!/bin/bash
  set -ex
  rm -rf venv
  python3 -m venv venv
  source venv/bin/activate
  pip install -r templater/requirements.txt

generate image workbench_version r_version python_version:
  python3 {{ justfile_directory() }}/templater/main.py {{image}} {{workbench_version}} {{r_version}} {{python_version}}

alias bake := build
build target export_options="--load" override_file="docker-bake.override.hcl":
  #!/bin/bash
  set -ex
  if [ -f "{{override_file}}" ]; then
    docker buildx bake -f {{justfile_directory()}}/docker-bake.hcl -f {{target}}/docker-bake.hcl -f {{override_file}} {{export_options}}
  else
    docker buildx bake -f {{justfile_directory()}}/docker-bake.hcl -f {{target}}/docker-bake.hcl {{export_options}}
  fi
