#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "Error: .env file not found next to the script!" >&2
    exit 1
fi

set -a
. .env
set +a

# Checking for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with root privileges."
  exit 1
fi

# Copying scripts to /usr/bin
echo "Copying to ${BIN_PATH}..."
cp "${AC_CONTAINER_START}" "${BIN_PATH}/${AC_CONTAINER_START}"
cp "${AC_CONTAINER_STOP}" "${BIN_PATH}/${AC_CONTAINER_STOP}"
chmod +x "${BIN_PATH}/${AC_CONTAINER_START}"
chmod +x "${BIN_PATH}/${AC_CONTAINER_STOP}"

# Copying the service and timer files to the appropriate directories
echo "Copying the systemd service and timer files..."
cp "${AC_SERVICE}"  "${SERVICE_PATH}/${AC_SERVICE}"
cp "${AC_TIMER}" "${SERVICE_PATH}/${AC_TIMER}"

# Reloading the systemd configuration
echo "Reloading systemd..."
systemctl daemon-reload

# Enabling and starting the timer
echo "Enabling and starting the timer and service..."
systemctl start "${AC_TIMER}"
systemctl enable "${AC_TIMER}"
echo "Installation completed successfully!"
