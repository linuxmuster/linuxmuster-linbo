#!/bin/bash
#
# compiles and creates grub2 pxe boot environment
# thomas@linuxmuster.net
# 15.07.2013
# GPL V3
#

GRUBDIR="$1"

#MODULES="net pxe tftp"
MODULES="tftp"

RC=0

cd $GRUBDIR

# compile
if [ ! -s grub-mkimage ]; then
 echo "[1mBuilding grub...[0m"
 HOST_CFLAGS="-g -Wall -Wno-error=unused-result -O0"
 CFLAGS=""
 ./autogen.sh
 ./configure --prefix=/usr
 make || RC=1
 for i in bios-setup editenv mkimage mkrelpath probe; do
  strip grub-$i
 done
fi

if [ ! -s pxegrub.0 ]; then
 echo "[1mBuilding pxegrub.0...[0m"
 ./grub-mkimage -d grub-core -o pxegrub.0 -O i386-pc-pxe -p /grub $MODULES || RC=1
fi

exit "$RC"
