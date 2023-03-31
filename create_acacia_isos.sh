#!/bin/bash

SCRIPT_DIR=$(dirname $(realpath $0))
DATE=$(date +"%d.%m.%4Y")

echo "Creating AcaciaLinux ISOs..."

mkdir -pv $SCRIPT_DIR/builds/{core,core-fw,desk,desk-fw}

create_iso() {
     ACACIA_ROOT=$SCRIPT_DIR/builds/$1 SQUASHFS=$2 ISO=$3 ISO_PKGS=$4 $SCRIPT_DIR/mkiso.sh
}

create_iso core core.squash AcaciaLinux-core-$DATE.iso
create_iso core-fq core-fw.squash AcaciaLinux-core-fw-$DATE.iso "linux-firmware"

create_iso desk desk.squash AcaciaLinux-desk-$DATE.iso "sway xorg-xinit xorg-fbdev xorg-libinput llvm alacritty"
create_iso desk-fw desk-fw.squash AcaciaLinux-desk-fw-$DATE.iso "linux-firmware sway xorg-xinit xorg-fbdev xorg-libinput llvm alacritty"


