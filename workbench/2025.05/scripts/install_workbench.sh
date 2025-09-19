#!/bin/bash
set -euo pipefail

# Output delimiter
d="===="

# Update apt repositories
apt-get update -yq

echo "$d Install Posit Workbench 2025.05.1+513.pro3 $d"

RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf rstudio-server=2025.05.1+513.pro3
apt-mark hold rstudio-server

# Clean up
apt-get clean -yqq && \
rm -rf /var/lib/apt/lists/*
