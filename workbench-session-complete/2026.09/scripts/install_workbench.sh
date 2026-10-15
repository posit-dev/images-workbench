#!/bin/bash
set -euo pipefail

# Output delimiter
d="===="
package_name="rstudio-server"

# Update apt repositories
apt-get update -yq

echo "$d Fetching Posit Workbench 2026.09.0+174.pro3 $d"
# For non-development versions, download the deb package using apt-get. The
# version is pinned exactly: the Posit open repo also carries a same-numbered
# non-pro build (e.g. 2026.08.1+195 alongside 2026.08.1+195.pro1) and only the
# `.pro1` package is Workbench.
apt-get download "${package_name}=2026.09.0+174.pro3"
deb_file="$(pwd)/$(ls ${package_name}*.deb)"

# Install the deb's declared dependencies up front. dpkg cannot resolve them
# itself, and the `dpkg --unpack` below has to succeed before the postinst can
# be patched.
# shellcheck disable=SC2046
apt-get install -yq $(dpkg -I "$deb_file" | grep '^ Depends:' | sed 's/^ Depends: //' | tr ',' '\n' | awk '{print $1}' | tr -d '(')

# Patch the installer so installing Workbench does not also START Workbench.
# `dpkg --unpack` lays the files down and writes the maintainer scripts WITHOUT
# running the postinst, which gives us a window to edit it before `dpkg
# --configure` executes it below. Each edit removes one thing that only makes
# sense on a real server host:
#   * force-suspend-all  -- talks to a running rserver that does not exist here
#   * systemctl enable   -- there is no init system in a container, and a
#                           session image must never start a Workbench server
#   * the license-initialization block -- would bake license state into the
#                           image layer (it is also gated by the
#                           RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 build
#                           arg; both are applied, belt and braces)
# Deliberately NOT patched out are the last two things the postinst does, which
# this image actively wants: it repoints
# /usr/lib/${TRIPLET}/libnss_pwb.so.2 at the real
# /usr/lib/rstudio-server/bin/libnss_pwb.so, and re-inserts `pwb` into
# /etc/nsswitch.conf.
echo "$d Patching ${deb_file} $d"
dpkg --unpack "${deb_file}"
sed -i 's/^rstudio-server force-suspend-all/# rstudio-server force-suspend-all/' /var/lib/dpkg/info/rstudio-server.postinst
sed -i 's/systemctl enable rstudio-server.service/# systemctl enable rstudio-server.service/g' /var/lib/dpkg/info/rstudio-server.postinst
sed -i 's/systemctl enable rstudio-launcher.service/# systemctl enable rstudio-launcher.service/g' /var/lib/dpkg/info/rstudio-server.postinst
awk '/if test "\$RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION" != "1"/ { skip=1 }
    skip { if (/fi/) { skip=0 } next }
    { print }
' "/var/lib/dpkg/info/rstudio-server.postinst" > "/var/lib/dpkg/info/rstudio-server.postinst.tmp" && mv "/var/lib/dpkg/info/rstudio-server.postinst.tmp" "/var/lib/dpkg/info/rstudio-server.postinst"

# Install Workbench
echo "$d Install Posit Workbench 2026.09.0+174.pro3 $d"
dpkg --configure "${package_name}"
apt-get install -yf
rm -f "${deb_file}"

# Clean up
apt-get clean -yqq && \
rm -rf /var/lib/apt/lists/*
