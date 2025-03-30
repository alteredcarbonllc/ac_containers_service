#!/bin/bash

if [ ! -f .env ]; then
    echo "Error: .env file not found!" >&2
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

# Stopping and disabling the service and timer first
echo "Stopping and disabling the timer and service..."
systemctl stop "${AC_TIMER}"
systemctl disable "${AC_SERVICE}"

# Reloading systemd configuration to reflect the changes
echo "Reloading systemd..."
systemctl daemon-reload

# Removing the service and timer files
echo "Removing the systemd service and timer files..."
rm -f "${SERVICE_PATH}/${AC_SERVICE}"
rm -f "${SERVICE_PATH}/${AC_TIMER}"

# Removing the executable scripts
echo "Removing the executable scripts..."
rm -f "${BIN_PATH}/${AC_CONTAINER_START}"
rm -f "${BIN_PATH}/${AC_CONTAINER_STOP}"

echo "Uninstallation completed successfully!"
