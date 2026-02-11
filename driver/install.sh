#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)."
  exit 1
fi

DRIVER_NAME="hp-wmi-dkms"
DRIVER_VERSION="0.3.0"
GROUP_NAME="hpfan"

echo "=== HP Victus WMI Driver Installer ==="

echo "[1/4] Checking/Creating user group '$GROUP_NAME'..."
groupadd -f $GROUP_NAME
echo "Group '$GROUP_NAME' is ready."

echo "[2/4] Setting up Kernel Driver..."
mkdir -p /usr/src/$DRIVER_NAME-$DRIVER_VERSION
cp -r ./* /usr/src/$DRIVER_NAME-$DRIVER_VERSION/

dkms remove -m $DRIVER_NAME -v $DRIVER_VERSION --all 2>/dev/null || true
dkms add -m $DRIVER_NAME -v $DRIVER_VERSION
dkms build -m $DRIVER_NAME -v $DRIVER_VERSION
dkms install -m $DRIVER_NAME -v $DRIVER_VERSION

echo "[3/4] Installing permissions rule..."
if [ -f "99-hp-fan-control.rules" ]; then
    cp 99-hp-fan-control.rules /etc/udev/rules.d/
    udevadm control --reload-rules
    udevadm trigger
else
    echo "ERROR: 99-hp-fan-control.rules not found!"
fi

echo "[4/4] Loading module..."
modprobe -r hp-wmi
modprobe hp-wmi

echo "-----------------------------------------------------"
echo "SUCCESS! Driver installed."
echo ""
echo "IMPORTANT STEP:"
echo "To control fans, you must add your user to the '$GROUP_NAME' group:"
echo ""
echo "  sudo usermod -aG $GROUP_NAME \$USER"
echo ""
echo "Then LOGOUT and LOGIN again."
echo "-----------------------------------------------------"