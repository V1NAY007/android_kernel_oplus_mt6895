#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_ROOT/out/android12-5.10/dist"

echo "Enter zephyr-kernel path:"
read -r KERNEL_DIR

if [ ! -d "$DIST_DIR" ]; then
    echo "ERROR: Dist directory not found:"
    echo "$DIST_DIR"
    exit 1
fi

if [ ! -d "$KERNEL_DIR" ]; then
    echo "ERROR: Destination directory not found:"
    echo "$KERNEL_DIR"
    exit 1
fi

echo
echo "========================================"
echo "Source      : $DIST_DIR"
echo "Destination : $KERNEL_DIR"
echo "========================================"

#
# Image.gz
#
if [ -f "$DIST_DIR/Image.gz" ]; then
    echo
    echo "[+] Updating Image.gz"
    cp -fv "$DIST_DIR/Image.gz" "$KERNEL_DIR/Image.gz"
else
    echo "[!] Image.gz not found in dist"
fi

#
# DTBs
#
echo
echo "[+] Updating DTBs"

find "$DIST_DIR" -maxdepth 1 -type f -name "*.dtb" | while read -r SRC_DTB; do
    DTB_NAME="$(basename "$SRC_DTB")"
    DEST_DTB="$KERNEL_DIR/dtb/$DTB_NAME"

    if [ -f "$DEST_DTB" ]; then
        cp -fv "$SRC_DTB" "$DEST_DTB"
    else
        echo "    Skipping $DTB_NAME (not present in destination)"
    fi
done

#
# Modules
#
echo
echo "[+] Updating modules"

find "$DIST_DIR" -type f -name "*.ko" | while read -r SRC_KO; do
    MOD_NAME="$(basename "$SRC_KO")"

    FOUND=0

    while read -r DEST_KO; do
        [ -z "$DEST_KO" ] && continue
        cp -fv "$SRC_KO" "$DEST_KO"
        FOUND=1
    done < <(find "$KERNEL_DIR/modules" -type f -name "$MOD_NAME")

    if [ "$FOUND" -eq 0 ]; then
        echo "    Skipping $MOD_NAME (not present in destination)"
    fi
done

echo
echo "========================================"
echo "Done."
echo "========================================"
