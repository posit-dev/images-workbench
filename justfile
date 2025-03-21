#!/usr/bin/env just --justfile

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
  #!/bin/bash
  set -eo pipefail

  RELEASE_API_ENDPOINT="/repos/posit-dev/pti/releases/latest"
  GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}"

  tag_name="$(gh --cache=1800s api $RELEASE_API_ENDPOINT --jq '.tag_name')"
  release_version="${tag_name#v}"
  assets="$(gh --cache=1800s api $RELEASE_API_ENDPOINT --jq '.assets.[] | [{name: .name, asset_url: .url}]')"

  PTI_DST_DIR="$(pwd)/pti_${release_version}"
  mkdir -p "${PTI_DST_DIR}"


  echo "$assets" | jq -c '.[]' | while read -r asset; do
      name=$(echo "$asset" | jq -r ".name")
      asset_url=$(echo "$asset" | jq -r ".asset_url")

      curl -sSL \
          -H 'Accept: application/octet-stream' \
          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
          "${asset_url}" \
          -o "${PTI_DST_DIR}/${name}"
  done

  cd "${PTI_DST_DIR}"
  shasum -c pti*checksums.txt
  chmod +rx pti*linux_amd64
