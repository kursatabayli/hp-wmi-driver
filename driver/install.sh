#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)."
  exit 1
fi

DRIVER_NAME="hp-wmi-dkms"
DRIVER_VERSION="0.3.0"

echo "=== HP Victus WMI Driver Installer ==="

echo "[1/2] Setting up Kernel Driver..."
mkdir -p /usr/src/$DRIVER_NAME-$DRIVER_VERSION
cp -r ./* /usr/src/$DRIVER_NAME-$DRIVER_VERSION/

dkms remove -m $DRIVER_NAME -v $DRIVER_VERSION --all 2>/dev/null || true
dkms add -m $DRIVER_NAME -v $DRIVER_VERSION
dkms build -m $DRIVER_NAME -v $DRIVER_VERSION
dkms install -m $DRIVER_NAME -v $DRIVER_VERSION

echo "[2/2] Loading module..."
modprobe -r hp-wmi
modprobe hp-wmi

echo "-----------------------------------------------------"
echo "SUCCESS! Driver installed."
echo "-----------------------------------------------------"