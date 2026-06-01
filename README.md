# HP Victus WMI Driver (Linux Kernel Module)

![Platform](https://img.shields.io/badge/platform-Linux-green.svg)
![License](https://img.shields.io/badge/license-GPLv3-blue.svg)

This repository contains a modified Linux kernel module (`hp-wmi`) that enables **manual fan control** (PWM) for **HP Victus** laptops. It exposes the raw fan control interface via standard `hwmon` sysfs paths, allowing users to control CPU and GPU fans independently.

This driver is a dependency for the **[HpFanControl](https://github.com/kursatabayli/HpFanControl)** application but can also be used standalone or with other tools like **CoolerControl**.

---

## Features

- **Manual PWM Control:** Enables writing to `pwm1` (CPU) and `pwm2` (GPU) interfaces.
- **Independent Control:** Patched to allow separate control of CPU and GPU fans (unlike the stock driver).
- **Standard Hwmon Interface:** Compatible with any Linux tool that uses `lm-sensors` or `sysfs` (e.g., `fancontrol`, `CoolerControl`).

---

## Credits & Upstream Status

This driver is based on the work by **Krishna Chomal** and other contributors in the Linux Kernel `platform-drivers-x86` tree.

* **[PATCH] [hp-wmi: add manual fan control for Victus S models](https://git.kernel.org/pub/scm/linux/kernel/git/pdx86/platform-drivers-x86.git/commit/drivers/platform/x86/hp/hp-wmi.c?h=for-next&id=46be1453e6e61884b4840a768d1e8ffaf01a4c1c)** *(Enables the raw PWM control interface)*
* **[PATCH] [hp-wmi: implement fan keep-alive](https://git.kernel.org/pub/scm/linux/kernel/git/pdx86/platform-drivers-x86.git/commit/drivers/platform/x86/hp/hp-wmi.c?h=for-next&id=c203c59fb5de1b1b8947d61176e868da1130cbeb)** *(Ensures safety/stability during manual operation)*

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

This script will compile and install the kernel module via DKMS.

---

### Manual Testing (Optional)
After installation and reboot, you can verify it works by checking the permissions:

```sh
ls -l /sys/class/hwmon/hwmon*/pwm1_enable
```

**Expected Output:**
`-rw-rw-r-- 1 root ...`

If you see `root` and permissions are `rw-rw-r--`, the installation is successful.

---

## Uninstallation

To remove the driver:

```sh
sudo ./uninstall.sh
```
---

## Compatibility

- ✅ **HP Victus 16-s0xxx:** Fully supported and tested.
- ❓ **HP Omen:** Likely compatible (shares similar WMI IDs), but untested. Use at your own risk.

## ⚠️ Disclaimer

This software modifies hardware fan settings via a custom kernel module. The software is provided "as is". The developer cannot be held responsible for any hardware or software issues that may arise from use.
