#!/bin/bash

set -e
if [[ "${STARTUP_DEBUG_MODE:-0}" -eq 1 ]]; then
  set -x
fi

# Deactivate license when the process exits
deactivate() {
    echo "== Exiting =="
    rstudio-server stop

    echo "Deactivating license ..."
    is_deactivated=0
    retries=0
    while [[ $is_deactivated -ne 1 ]] && [[ $retries -le 3 ]]; do
      /usr/lib/rstudio-server/bin/license-manager deactivate >/dev/null 2>&1
      is_deactivated=1
      ((retries+=1))
      # shellcheck disable=SC2045
      for file in $(ls -A /var/lib/.local); do
        if [ -s "/var/lib/.local/$file" ]; then
          if [[ $retries -lt 3 ]]; then
            echo "License did not deactivate, retry ${retries}..."
            is_deactivated=0
          else
            echo "Unable to deactivate license. If you encounter issues activating your product in the future, please contact Posit support."
          fi
          continue
        fi
      done
    done
}
trap deactivate EXIT

# Backward compatibility for RSW_ prefix
PWB_TESTUSER=${PWB_TESTUSER:-${RSW_TESTUSER}}
PWB_TESTUSER_UID=${PWB_TESTUSER_UID:-${RSW_TESTUSER_UID}}
PWB_TESTUSER_PASSWD=${PWB_TESTUSER_PASSWD:-${RSW_TESTUSER_PASSWD}}

verify_installation(){
   echo "==VERIFY INSTALLATION==";
   mkdir -p "$DIAGNOSTIC_DIR"
   chmod 777 "$DIAGNOSTIC_DIR"
   rstudio-server verify-installation --verify-user="$PWB_TESTUSER" | tee "$DIAGNOSTIC_DIR/verify.log"
}

# Backward compatibility for RSW_ and RSP_ prefixes
PWB_LICENSE=${PWB_LICENSE:-${RSW_LICENSE:-${RSP_LICENSE}}}
PWB_LICENSE_SERVER=${PWB_LICENSE_SERVER:-${RSW_LICENSE_SERVER:-${RSP_LICENSE_SERVER}}}
PWB_LICENSE_FILE_PATH=${PWB_LICENSE_FILE_PATH:-${RSW_LICENSE_FILE_PATH}}

# Activate License
PWB_LICENSE_FILE_PATH=${PWB_LICENSE_FILE_PATH:-/etc/rstudio-server/license.lic}
if [ -n "$PWB_LICENSE" ]; then
    /usr/lib/rstudio-server/bin/license-manager activate "$PWB_LICENSE"
elif [ -n "$PWB_LICENSE_SERVER" ]; then
    /usr/lib/rstudio-server/bin/license-manager license-server "$PWB_LICENSE_SERVER"
elif test -f "$PWB_LICENSE_FILE_PATH"; then
    /usr/lib/rstudio-server/bin/license-manager activate-file "$PWB_LICENSE_FILE_PATH"
fi

# ensure these cannot be inherited by child processes
unset PWB_LICENSE
unset PWB_LICENSE_SERVER
unset RSP_LICENSE
unset RSP_LICENSE_SERVER
unset RSW_LICENSE
unset RSW_LICENSE_SERVER

# Create one user
if [ "$(getent passwd "$PWB_TESTUSER_UID")" ] ; then
    echo "UID $PWB_TESTUSER_UID already exists, not creating $PWB_TESTUSER test user";
else
    if [ -z "$PWB_TESTUSER" ]; then
        echo "Empty 'PWB_TESTUSER' variables, not creating test user";
    else
        if [ -z "$PWB_TESTUSER_UID" ]; then
            PWB_TESTUSER_UID=10000
        fi
        useradd -m -s /bin/bash -u "$PWB_TESTUSER_UID" -U "$PWB_TESTUSER"
        echo "$PWB_TESTUSER:$PWB_TESTUSER_PASSWD" | sudo chpasswd
    fi
fi

# Backward compatibility for RSW_ prefix
PWB_LAUNCHER=${PWB_LAUNCHER:-${RSW_LAUNCHER}}
PWB_LAUNCHER_TIMEOUT=${PWB_LAUNCHER_TIMEOUT:-${RSW_LAUNCHER_TIMEOUT}}

# Start Launcher
if [ "$PWB_LAUNCHER" == "true" ]; then
  echo "Waiting for launcher to startup... to disable set PWB_LAUNCHER=false"
  wait-for-it.sh localhost:5559 -t "$PWB_LAUNCHER_TIMEOUT"
fi

# Check diagnostic configurations
if [ "$DIAGNOSTIC_ENABLE" == "true" ]; then
  verify_installation
  if [ "$DIAGNOSTIC_ONLY" == "true" ]; then
    echo "$(<"$DIAGNOSTIC_DIR"/verify.log)";
    echo "Exiting script because DIAGNOSTIC_ONLY=${DIAGNOSTIC_ONLY}";
    exit 0
  fi;
else
  echo "not running verify installation because DIAGNOSTIC_ENABLE=${DIAGNOSTIC_ENABLE}";
fi

# the main container process
# cannot use "exec" or the "trap" will be lost
/usr/lib/rstudio-server/bin/rserver --server-daemonize 0 > /dev/stderr
