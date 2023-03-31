#!/bin/bash

SCRIPT_DIR=$(dirname $(realpath $0))
DATE=$(date +"%d.%m.%4Y")

echo "Creating AcaciaLinux ISOs..."

mkdir -pv $SCRIPT_DIR/builds/{core,core-fw,desk,desk-fw}

create_iso() {
     ACACIA_ROOT=$SCRIPT_DIR/builds/$1/root SQUASHFS=$SCRIPT_DIR/builds/$1.squash ISO=$2 ISO_PKGS=$3 $SCRIPT_DIR/mkiso.sh
}

create_iso core AcaciaLinux-core-$DATE.iso
create_iso core-fw AcaciaLinux-core-fw-$DATE.iso "linux-firmware"

create_iso desk AcaciaLinux-desk-$DATE.iso "sway xorg-xinit xorg-fbdev xorg-libinput llvm alacritty"
create_iso desk-fw AcaciaLinux-desk-fw-$DATE.iso "linux-firmware sway xorg-xinit xorg-fbdev xorg-libinput llvm alacritty"


