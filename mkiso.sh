#/bin/bash

set -e

SCRIPT_DIR=$(dirname $(realpath $0))

ACACIA_ROOT=./acacia_root
SQUASHFS=$SCRIPT_DIR/squashfs.img
LEAF=leaf
BASE_PKGS="base lvm2 systemd dbus iproute2 tar cryptsetup squashfs-tools linux-lts dracut bash grub libisoburn mtools"
ISO_PKGS="setup-scripts vim networkmanager e2fsprogs dosfstools leaf seed"

$LEAF --root $ACACIA_ROOT update --noAsk
$LEAF --root $ACACIA_ROOT --downloadCache $SCRIPT_DIR/leaf_download_cache install --noAsk -f $BASE_PKGS $ISO_PKGS

echo "Removing leaf cache..."
rm -rf $ACACIA_ROOT/var/cache/leaf

echo "Cleaning pycaches..."
find $ACACIA_ROOT -name __pycache__ -type d -exec rm -rf {} 2>&1 > /dev/null \; 2>&1 > /dev/null || true

echo "Removing locale-archive..."
rm -rf $ACACIA_ROOT/usr/lib/locale/locale-archive

echo "Removing iso directory if existing before initramfs build..."
rm -rf $ACACIA_ROOT/iso

echo "Setting password..."
systemd-nspawn -D $ACACIA_ROOT usermod --password $(echo root | openssl passwd -1 -stdin) root

echo "Enabling autologin..."
patch $ACACIA_ROOT/usr/lib/systemd/system/getty@.service -i $SCRIPT_DIR/getty.patch

echo "Enabling NetworkManager..."
systemd-nspawn -D $ACACIA_ROOT systemctl enable NetworkManager

echo "Generating initramfs..."
cp -v $SCRIPT_DIR/01-liveos.conf $ACACIA_ROOT/etc/dracut.conf.d/01-liveos.conf
systemd-nspawn -D $ACACIA_ROOT dracut --kver 5.15.44 --zstd --no-hostonly --add dmsquash-live --force /boot/initramfs-acacia-lts.img

echo "Generating squashfs..."
mksquashfs $ACACIA_ROOT $SQUASHFS

echo "Creating iso directory..."
systemd-nspawn -D $ACACIA_ROOT mkdir -pv /iso/boot/grub/
systemd-nspawn -D $ACACIA_ROOT mkdir -pv /iso/LiveOS/

echo "Copying grub config..."
cp -v $SCRIPT_DIR/grub.cfg $ACACIA_ROOT/iso/boot/grub/grub.cfg

echo "Copying squashfs..."
cp -v $SQUASHFS $ACACIA_ROOT/iso/LiveOS/squashfs.img

echo "Creating grub-rescue..."
systemd-nspawn -D $ACACIA_ROOT grub-mkrescue /iso -o ACACIA.iso -- -volid ACACIA

echo "Moving ISO out of root..."
mv -v $ACACIA_ROOT/ACACIA.iso $SCRIPT_DIR/ACACIA.iso

