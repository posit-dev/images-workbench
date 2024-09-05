#!/usr/bin/env just --justfile


init:
  #!/bin/bash
  set -ex
  rm -rf venv
  python3 -m venv venv
  source venv/bin/activate
  pip install -r templater/requirements.txt

generate os os_version:
  python3 {{ justfile_directory() }}/templater/main.py {{os}} {{os_version}}
