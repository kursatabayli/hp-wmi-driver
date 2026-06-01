#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)."
  exit 1
fi

DRIVER_NAME="hp-wmi-dkms"
DRIVER_VERSION="0.3.0"

echo "=== HP Victus WMI Driver Uninstaller ==="

echo "[1/2] Unloading kernel module..."
modprobe -r hp-wmi || true

echo "[2/2] Removing driver from DKMS..."
dkms remove -m $DRIVER_NAME -v $DRIVER_VERSION --all 2>/dev/null || true
rm -rf /usr/src/$DRIVER_NAME-$DRIVER_VERSION

echo "-----------------------------------------------------"
echo "Uninstallation Complete."
echo "Your system is clean."
echo "-----------------------------------------------------"