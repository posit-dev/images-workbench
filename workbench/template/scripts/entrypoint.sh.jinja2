#!/bin/bash
set -euo pipefail

# sssd is a root-only daemon; stage its Pebble layer only when running as root
# and not disabled, so sssd never starts non-root and shuts the container down.
if [ "$(id -u)" -eq 0 ] && [ "${PWB_SSSD:-true}" = "true" ]; then
  install -m 0644 /opt/startup-templates/002-sssd.yaml "$PEBBLE/layers/002-sssd.yaml"
fi

exec pebble run --verbose "$@"
