#!/bin/bash
# USBian Linux Installer
set -e

DEBIAN_ISO_URL="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-12.10.0-amd64-standard.iso"

echo "[1/3] Downloading Debian Live ISO..."
wget -q --show-progress "$DEBIAN_ISO_URL" -O USBian.iso

echo "[2/3] Flashing to drive (WARNING: FINAL STEP)..."
lsblk -o NAME,MODEL,SIZE
read -p "Enter target USB device (e.g., /dev/sdh): " TARGET

if [ ! -b "$TARGET" ]; then
    echo "ERROR: $TARGET is not a valid block device!"
    exit 1
fi

sudo dd if=USBian.iso of=$TARGET bs=4M status=progress conv=fsync
echo "[3/3] Installation complete!"