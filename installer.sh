#!/bin/bash
# USBian Linux Installer
set -e
echo "[1/4] Starting USBian installation..."
mkdir -p tmp_blocks
for i in {00..41}; do
    echo "[INFO] Downloading block $i..."
    wget -q "https://github.com/YOUR_USERNAME/USBian/releases/download/v1.0/debian_part_$i" -O "tmp_blocks/part_$i"
done
echo "[2/4] Joining blocks..."
cat tmp_blocks/part_* > USBian.img.gz
echo "[3/4] Decompressing..."
gunzip -f USBian.img.gz
echo "[4/4] Flashing to drive (WARNING: FINAL STEP)..."
lsblk
read -p "Enter target USB device (e.g., /dev/sdh): " TARGET
sudo dd if=USBian.img of=$TARGET bs=4M status=progress conv=fsync
echo "Installation complete."
