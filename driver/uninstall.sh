#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)."
  exit 1
fi

DRIVER_NAME="hp-wmi-dkms"
DRIVER_VERSION="0.3.0"
GROUP_NAME="hpfan"

echo "=== HP Victus WMI Driver Uninstaller ==="

echo "[1/4] Unloading kernel module..."
modprobe -r hp-wmi || true

echo "[2/4] Removing driver from DKMS..."
dkms remove -m $DRIVER_NAME -v $DRIVER_VERSION --all 2>/dev/null || true
rm -rf /usr/src/$DRIVER_NAME-$DRIVER_VERSION

echo "[3/4] Removing permissions rule..."
if [ -f "/etc/udev/rules.d/99-hp-fan-control.rules" ]; then
    rm -f /etc/udev/rules.d/99-hp-fan-control.rules
    udevadm control --reload-rules
    udevadm trigger
    echo "Rule removed."
else
    echo "Rule not found, skipping."
fi

echo "[4/4] Removing '$GROUP_NAME' group..."
if getent group $GROUP_NAME > /dev/null; then
    groupdel $GROUP_NAME
    echo "Group '$GROUP_NAME' removed."
else
    echo "Group '$GROUP_NAME' not found, skipping."
fi

echo "-----------------------------------------------------"
echo "Uninstallation Complete."
echo "Your system is clean."
echo "-----------------------------------------------------"