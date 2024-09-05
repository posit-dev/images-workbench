#!/bin/bash
set -euo pipefail

# Output delimiter
d="===="

# Set variables
SCRIPTS_DIR=${SCRIPTS_DIR:-/opt/positscripts}
OS_URL=${OS_URL:-jammy}
WORKBENCH_NAME=${WORKBENCH_NAME:-rstudio-workbench}
WORKBENCH_URL_VERSION=$(echo -n "${WORKBENCH_VERSION}" | sed 's/+/-/g')
WORKBENCH_DOWNLOAD_URL=${WORKBENCH_DOWNLOAD_URL:-https://download2.posit.co/server/$OS_URL/amd64/$WORKBENCH_NAME-$WORKBENCH_URL_VERSION-amd64.deb}

# Update apt repositories
$SCRIPTS_DIR/apt.sh --update

# Fetch Workbench debian package
echo "$d Fetching Workbench package $d"
curl -fsSL -o /tmp/workbench.deb ${WORKBENCH_DOWNLOAD_URL}

# Verify Workbench package
echo "$d Verify Workbench package $d"
gpg --keyserver keys.openpgp.org --recv-keys 51C0B5BB19F92D60
dpkg-sig --verify /tmp/workbench.deb

# Patch Workbench package to not attempt service startup
echo "$d Patching Workbench package installation scripts $d"
dpkg --unpack /tmp/workbench.deb
# FIXME(ianpittwood): This should be fixed in the debian packages.
# Workaround since RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1
sed -i 's/systemctl enable rstudio-server.service/#systemctl enable rstudio-server.service/g' /var/lib/dpkg/info/rstudio-server.postinst
sed -i 's/systemctl enable rstudio-launcher.service/#systemctl enable rstudio-launcher.service/g' /var/lib/dpkg/info/rstudio-server.postinst
sed -i 's/$RSERVER_ADMIN_SCRIPT start/echo "Skipping server startup."/g' /var/lib/dpkg/info/rstudio-server.postinst
sed -i 's/$LAUNCHER_ADMIN_SCRIPT start/echo "Skipping launcher startup."/g' /var/lib/dpkg/info/rstudio-server.postinst

# Install Workbench
echo "$d Install Workbench $d"
dpkg --configure rstudio-server
apt-get install -yf
rm -f /tmp/{{ workbench_name }}.deb

# Clean up
$SCRIPTS_DIR/apt.sh --clean
