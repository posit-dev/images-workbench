#!/bin/bash
set -euo pipefail

# sssd is a root-only daemon; install its supervisord program only when running
# as root and not disabled. Skips when non-root or when the user-provisioning
# directory is a mount point (emptyDir, ConfigMap, etc.), so sssd never starts
# non-root and FATAL-crashes the container via the process-monitor eventlistener.
if [ "$(id -u)" -eq 0 ] && [ "${PWB_SSSD:-true}" = "true" ] \
   && ! mountpoint -q /startup/user-provisioning; then
  install -m 0644 /opt/startup-templates/sssd.conf /startup/user-provisioning/sssd.conf
fi

exec "$@"
