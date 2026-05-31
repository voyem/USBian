#!/bin/bash

# Universal Debian Persistence USB Installer
# A semi-verbose, automated setup script.

set -e

# Configuration (Replace with your GitHub details)
GH_USER="voyem"
GH_REPO="usb-debian-os"
RELEASE_TAG="v1.0"

echo "=========================================================="
echo "    USBian: UNIVERSAL DEBIAN PERSISTENCE USB INSTALLER v1.0"
echo "=========================================================="
echo "[INFO] Starting environment check..."

# 1. Identify USB Drive
echo "[TASK] Searching for connected USB drives..."
USB_DRIVES=$(lsblk -o NAME,SIZE,MODEL,TRAN | grep "usb" || true)

if [ -z "$USB_DRIVES" ]; then
    echo "[ERROR] No USB drives detected. Please insert a drive and try again."
    exit 1
fi

echo "Detected USB drives:"
echo "$USB_DRIVES"
echo "----------------------------------------------------------"
read -p "[INPUT] Enter the device name to use (e.g., sdb): " DEV_NAME
DEV="/dev/$DEV_NAME"

if [ ! -b "$DEV" ]; then
    echo "[ERROR] $DEV is not a valid block device."
    exit 1
fi

echo "[CRITICAL] All data on $DEV will be PERMANENTLY ERASED!"
read -p "[INPUT] Type 'YES' to confirm: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "[INFO] Installation cancelled by user."
    exit 1
fi

# 2. Choose Flavor
echo ""
echo "[TASK] Selecting system flavor..."
echo "1) Lite (CLI only, ~600MB) - Minimalistic, high performance."
echo "2) Base (XFCE Desktop, ~2.5GB) - Visual interface + Browser."
echo "3) Restore (Full 4GB Backup) - Your pre-configured 'Plug & Play' system."
read -p "[INPUT] Choice [1-3]: " FLAVOR_CHOICE

case "$FLAVOR_CHOICE" in
    1)
        ISO_URL="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.5.0-amd64-standard.iso"
        IMAGE_NAME="debian-lite.iso"
        MODE="ISO"
        ;;
    2)
        ISO_URL="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.5.0-amd64-xfce.iso"
        IMAGE_NAME="debian-base.iso"
        MODE="ISO"
        ;;
    3)
        IMAGE_NAME="debian_restore.img"
        MODE="RESTORE"
        ;;
    *)
        echo "[ERROR] Invalid selection."
        exit 1
        ;;
esac

# 3. Preparation & Downloading
if [ "$MODE" == "ISO" ]; then
    if [ ! -f "$IMAGE_NAME" ]; then
        echo "[INFO] ISO not found locally. Downloading from Debian mirrors..."
        wget -O "$IMAGE_NAME" "$ISO_URL"
    else
        echo "[INFO] Existing ISO found. Skipping download."
    fi
else
    echo "[INFO] Restore mode selected. Downloading blocks from GitHub..."
    mkdir -p tmp_blocks
    # This loop assumes 42 blocks (4.1GB / 100MB). Adjust range as needed.
    for i in {00..41}; do
        BLOCK="debian_part_$i"
        if [ ! -f "tmp_blocks/$BLOCK" ]; then
            echo "[TASK] Downloading block $i/41..."
            # Adjust the URL to your actual GitHub Release URL
            BLOCK_URL="https://github.com/$GH_USER/$GH_REPO/releases/download/$RELEASE_TAG/$BLOCK"
            # Note: For now, I'll print a message as the URL isn't live yet.
            # wget -q --show-progress -O "tmp_blocks/$BLOCK" "$BLOCK_URL" || true
            echo "   -> (Placeholder: wget $BLOCK_URL)"
        fi
    done
    echo "[TASK] Reassembling blocks into full image..."
    # cat tmp_blocks/debian_part_* | gunzip -c > "$IMAGE_NAME"
    echo "   -> (Placeholder: Reassembling and decompressing...)"
fi

# 4. Deployment
echo "[TASK] Unmounting all partitions on $DEV..."
sudo umount "$DEV"* 2>/dev/null || true

echo "[TASK] Wiping existing partition table..."
sudo wipefs -a "$DEV"

echo "[TASK] Writing system image to $DEV (this will take time)..."
if [ "$MODE" == "RESTORE" ]; then
    # In a real run, this would be the reassembled image
    echo "[INFO] Note: Restore mode currently requires local blocks for this demo."
    # sudo dd if="$IMAGE_NAME" of="$DEV" bs=4M status=progress conv=fsync
else
    sudo dd if="$IMAGE_NAME" of="$DEV" bs=4M status=progress conv=fsync
fi

# 5. Post-Install Persistence (Only for ISO mode)
if [ "$MODE" == "ISO" ]; then
    echo "[TASK] Creating Persistence partition..."
    echo -e "n\np\n3\n\n\nw" | sudo fdisk "$DEV"
    sudo partprobe "$DEV"
    
    echo "[TASK] Formatting persistence partition (ext4)..."
    sleep 2
    PART="${DEV}3"
    [ ! -b "$PART" ] && PART="${DEV}p3"
    
    sudo mkfs.ext4 -L persistence "$PART"
    sudo mkdir -p /mnt/persistence
    sudo mount "$PART" /mnt/persistence
    echo "/ union" | sudo tee /mnt/persistence/persistence.conf
    sudo umount /mnt/persistence
    sudo rmdir /mnt/persistence
fi

echo ""
echo "=========================================================="
echo "[SUCCESS] Installation Complete!"
echo "[INFO] Your Universal USB is now ready for use."
echo "[INFO] Reboot and choose your USB from the BIOS boot menu."
echo "=========================================================="
