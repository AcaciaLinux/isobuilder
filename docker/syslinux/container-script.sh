#!/bin/bash
# Builds syslinux from source.
# Taken from LinuxLiveKit, adapted for AcaciaLinux

set -e

echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list
apt-get update -y

CWD=$(pwd)
DIR="/boot/"

# download, unpack, and patch syslinux

apt-get --yes build-dep syslinux
mkdir -m 0777 /tmp/syslinux

cd /tmp/syslinux
apt-get source syslinux
apt-get --yes install upx
cd syslinux*/core

for file in fs/iso9660/iso9660.c fs/lib/loadconfig.c elflink/load_env32.c; do
   sed -i -r 's:"/",:"'$DIR'",\n\t"/",:' $file
done

cd ../

rm -f bios/core/isolinux.bin
rm -f bios/com32/elflink/ldlinux/ldlinux.c32
rm -f bios/com32/lib/libcom32.c32
rm -f bios/com32/libutil/libutil.c32
rm -f bios/com32/menu/vesamenu.c32
rm -f bios/extlinux/extlinux

make -j 8 -i

echo
echo "Copying files to $CWD ..."

cp bios/core/isolinux.bin $CWD
cp bios/com32/elflink/ldlinux/ldlinux.c32 $CWD
cp bios/com32/lib/libcom32.c32 $CWD
cp bios/com32/libutil/libutil.c32 $CWD
cp bios/com32/menu/vesamenu.c32 $CWD

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then ARCH=64; else ARCH=32; fi
EXTLINUX=extlinux.x$ARCH

strip --strip-unneeded bios/extlinux/extlinux
cp bios/extlinux/extlinux $CWD/extlinux.x$ARCH

echo "done"
