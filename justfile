#!/usr/bin/env just --justfile


init:
  #!/bin/bash
  set -ex
  rm -rf venv
  python3 -m venv venv
  source venv/bin/activate
  pip install -r tools/requirements.txt
  mkdir -p {{justfile_directory()}}/tools
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o {{justfile_directory()}}/tools/goss
  chmod +rx {{justfile_directory()}}/tools/goss
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/dgoss -o {{justfile_directory()}}/tools/dgoss
  chmod +rx {{justfile_directory()}}/tools/dgoss

generate image workbench_version r_version python_version:
  python3 {{ justfile_directory() }}/tools/templater.py {{image}} {{workbench_version}} {{r_version}} {{python_version}}

alias bake := build
build target export_options="--load" override_file="docker-bake.override.hcl":
  #!/bin/bash
  set -ex
  if [ -f "{{override_file}}" ]; then
    docker buildx bake -f {{justfile_directory()}}/docker-bake.hcl -f {{target}}/docker-bake.hcl -f {{override_file}} {{export_options}}
  else
    docker buildx bake -f {{justfile_directory()}}/docker-bake.hcl -f {{target}}/docker-bake.hcl {{export_options}}
  fi

test image version type os='ubuntu' os_version='22.04' registry='docker.io':
  #!/bin/bash
  set -x
  suffix=""
  if [[ "{{type}}" != "std" ]]; then
    suffix="-{{type}}"
  fi
  GOSS_PATH={{justfile_directory()}}/tools/goss \
  GOSS_FILES_PATH={{justfile_directory()}}/{{image}}/{{version}}/test \
    {{justfile_directory()}}/tools/dgoss run \
    -e IMAGE_TYPE="{{type}}" \
    -v {{justfile_directory()}}/common/{{os}}/{{os_version}}:/tmp/deps \
    {{registry}}/posit/{{image}}:{{os}}{{replace(os_version, ".", "")}}-{{replace_regex(version, "[+].*", "")}}${suffix}
