#!/bin/bash
set -euo pipefail

# Pre-create rstudio-server user so the deb postinst finds it and UID/GID stays 999
# across image rebuilds. Idempotent so a cached layer (or the postinst) that already
# created the account does not fail the build.
if ! getent group rstudio-server >/dev/null; then
    groupadd --system --gid 999 rstudio-server
fi
if ! getent passwd rstudio-server >/dev/null; then
    useradd --system --uid 999 --gid rstudio-server \
        --no-create-home --home-dir /var/lib/rstudio-server \
        --shell /usr/sbin/nologin \
        rstudio-server
fi
if [ "$(id -u rstudio-server)" != 999 ] || [ "$(id -g rstudio-server)" != 999 ]; then
    echo "ERROR: rstudio-server must be uid/gid 999, got uid=$(id -u rstudio-server) gid=$(id -g rstudio-server)" >&2
    exit 1
fi
