# USBian: Universal Debian Persistence USB

This project provides instructions and configuration for creating a "Plug and Play" Debian Linux USB drive with persistence. This allows you to carry a full terminal-ready OS on a USB stick that boots on almost any PC (BIOS or UEFI) and saves your files and settings.

## Features
- **Universal Boot:** Works on standard PC hardware.
- **Persistence:** Saves files, terminal history, and system changes across reboots.
- **Minimalistic:** Fast and lightweight terminal-focused environment.

## Requirements
- A USB drive (32GB recommended).
- A Debian Live ISO image.

## Quick Setup (Recommended)

The easiest way to create your USB is to use the automated installer script. You can run it directly from this repository:

```bash
chmod +x installer.sh
sudo ./installer.sh
```

The script will:
1.  Help you identify your USB drive.
2.  Let you choose between **Lite** (CLI only) and **Base** (XFCE Desktop).
3.  Automatically download the ISO, flash it, and configure persistence.

### Windows Setup

1.  Download `USBian_Installer.exe` from this repository.
2.  Run the `.exe`. It will download the necessary system blocks and reassemble the image.
3.  Once the image (`USBian_Restore.img.gz`) is ready, use a tool like **Rufus** or **BalenaEtcher** to flash it to your USB drive.

---

## Manual Setup Instructions (Advanced)

### 1. Flash the ISO
Flash the Debian Live ISO to your USB device (replace `/dev/sdX` with your USB device path):
```bash
sudo dd if=debian-live.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

### 2. Create Persistence Partition
Create a new partition in the remaining space:
```bash
sudo fdisk /dev/sdX
# Steps: n (new), p (primary), 3 (partition number), [default start], [default end], w (write)
```

### 3. Format and Configure Persistence
Format the partition and tell Debian to use it for data:
```bash
sudo mkfs.ext4 -L persistence /dev/sdX3
sudo mkdir -p /mnt/persistence
sudo mount /dev/sdX3 /mnt/persistence
echo "/ union" | sudo tee /mnt/persistence/persistence.conf
sudo umount /mnt/persistence
```

### 4. Booting
When booting from the USB, select the **"Persistence"** option from the GRUB boot menu.

## Backup & Restore
To backup the entire drive for later use:
```bash
sudo dd if=/dev/sdX of=debian_persistence_backup.img bs=4M status=progress
```

To restore to a new USB:
```bash
sudo dd if=debian_persistence_backup.img of=/dev/sdX bs=4M status=progress
```
