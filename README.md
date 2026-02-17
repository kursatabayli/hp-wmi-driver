# HP Victus WMI Driver (Linux Kernel Module)

![Platform](https://img.shields.io/badge/platform-Linux-green.svg)
![License](https://img.shields.io/badge/license-GPLv3-blue.svg)

This repository contains a modified Linux kernel module (`hp-wmi`) that enables **manual fan control** (PWM) for **HP Victus** laptops. It exposes the raw fan control interface via standard `hwmon` sysfs paths, allowing users to control CPU and GPU fans independently.

This driver is a dependency for the **[HP Fan Control GUI](https://github.com/kursatabayli/hp-fan-control)** application but can also be used standalone or with other tools like **CoolerControl**.

---

## Features

- **Manual PWM Control:** Enables writing to `pwm1` (CPU) and `pwm2` (GPU) interfaces.
- **Independent Control:** Patched to allow separate control of CPU and GPU fans (unlike the stock driver).
- **Standard Hwmon Interface:** Compatible with any Linux tool that uses `lm-sensors` or `sysfs` (e.g., `fancontrol`, `CoolerControl`).
- **Security Best Practices:** Uses a dedicated user group (`hpfan`) and `udev` rules to allow non-root access securely.

---

## Credits & Upstream Status

This driver is based on the work by **Krishna Chomal** and other contributors in the Linux Kernel `platform-drivers-x86` tree.

- **Core Logic:** Based on `hp-wmi` patches for manual fan control on Victus/Omen devices.
- **My Contribution:** Added a specific patch to **split CPU and GPU fan controls**, enabling independent regulation.

> **Note:** These features are expected to land in future official Linux Kernel versions (likely 7.0+). This DKMS module serves as a bridge until then.

---

## Installation

This driver uses **DKMS** (Dynamic Kernel Module Support) to ensure it survives kernel updates.

### Step 1: Install Dependencies

You need `dkms` and kernel headers for your current kernel.

* **Fedora:** `sudo dnf install dkms kernel-devel gcc make`
* **Ubuntu/Debian:** `sudo apt install dkms build-essential linux-headers-generic`
* **Arch:** `sudo pacman -S dkms linux-headers base-devel`

### Step 2: Install the Driver

1. Clone this repository or download the source.
2. Open a terminal inside the folder.
3. Run the installer script:

```sh
sudo ./install.sh
```

This script will:
1. Compile and install the kernel module via DKMS.
2. Create a dedicated user group named **`hpfan`**.
3. Install a `udev` rule to automatically grant permissions to this group.

### Step 3: Add Your User to the Group (Important!)

To control fans without `root` (sudo) privileges, you **must** add your user to the `hpfan` group created by the installer.

```sh
sudo usermod -aG hpfan $USER
```

> **⚠️ RESTART REQUIRED:** After running this command, you must **LOG OUT and LOG IN** (or restart your computer) for the group change to take effect.

---

## How It Works

### The `udev` Rule
The installer places a rule file at `/etc/udev/rules.d/99-hp-fan-control.rules`. This rule triggers whenever the `hp-wmi` driver is loaded:

```
ACTION=="add|change", SUBSYSTEM=="hwmon", ATTRS{name}=="hp", GROUP="hpfan", MODE="0664"

ACTION=="add|change", SUBSYSTEM=="hwmon", KERNEL=="hwmon*", ATTRS{name}=="hp", RUN+="/bin/sh -c 'chmod 664 /sys/class/hwmon/%k/pwm* && chgrp hpfan /sys/class/hwmon/%k/pwm*'"
```

This ensures that the PWM control files in `/sys/class/hwmon/...` are owned by the `hpfan` group and are writable by group members. This eliminates the need for unsafe `chmod 777` or running GUI apps as root.

### Manual Testing (Optional)
After installation and reboot, you can verify it works by checking the permissions:

```sh
ls -l /sys/class/hwmon/hwmon*/pwm1_enable
```

**Expected Output:**
`-rw-rw-r-- 1 root hpfan ...`

If you see `root hpfan` and permissions are `rw-rw-r--`, the installation is successful.

---

## Uninstallation

To remove the driver, the group, and the udev rule:

```sh
sudo ./uninstall.sh
```
---

## Compatibility

- ✅ **HP Victus 16-s0xxx:** Fully supported and tested.
- ❓ **HP Omen:** Likely compatible (shares similar WMI IDs), but untested. Use at your own risk.

## ⚠️ Disclaimer

This software modifies hardware fan settings via a custom kernel module. The software is provided "as is". The developer cannot be held responsible for any hardware or software issues that may arise from use.
