#!/bin/sh
#
# creates directory structure for grub network boot
# thomas@linuxmuster.net
# 20170726
# GPL V3
#

# read linuxmuster environment
. /usr/share/linuxmuster/defaults.sh || exit 1

# architectures
I386="i386-pc"
EFI32="i386-efi"
EFI64="x86_64-efi"

# dirs
SUBDIR="/boot/grub"
I386_DIR="/usr/lib/grub/$I386"
EFI32_DIR="/usr/lib/grub/$EFI32"
EFI64_DIR="/usr/lib/grub/$EFI64"

# image files
CORE_I386="$LINBOGRUBDIR/$I386/core"
CORE_EFI32="$LINBOGRUBDIR/$EFI32/core"
CORE_EFI64="$LINBOGRUBDIR/$EFI64/core"

# grub.cfg templates
GRUBCFG_TEMPLATE="$LINBOTPLDIR/grub.cfg.pxe"

# fonts
FONTS="unicode"

# make cd/usb boot images (efi only)
grub-mknetdir --modules="$GRUBEFIMODS $GRUBISOMODS" -d "$EFI32_DIR" --net-directory="$LINBODIR" --subdir="$SUBDIR"
grub-mknetdir --modules="$GRUBEFIMODS $GRUBISOMODS" -d "$EFI64_DIR" --net-directory="$LINBODIR" --subdir="$SUBDIR"
mv "$CORE_EFI32.efi" "$CORE_EFI32.iso"
mv "$CORE_EFI64.efi" "$CORE_EFI64.iso"

# make special purpose minimal netboot image for i386
grub-mknetdir --fonts="$GRUBFONT" -d "$I386_DIR" --net-directory="$LINBODIR" --subdir="$SUBDIR"
mv "$CORE_I386.0" "$CORE_I386.min"

# make standard netboot images
grub-mknetdir --fonts="$GRUBFONT" --modules="$GRUBI386MODS" -d "$I386_DIR" --net-directory="$LINBODIR" --subdir="$SUBDIR"
grub-mknetdir --fonts="$GRUBFONT" --modules="$GRUBEFIMODS" -d "$EFI32_DIR" --net-directory="$LINBODIR" --subdir="$SUBDIR"
grub-mknetdir --fonts="$GRUBFONT" --modules="$GRUBEFIMODS" -d "$EFI64_DIR" --net-directory="$LINBODIR" --subdir="$SUBDIR"

# copy remaining files
rsync -a "$I386_DIR/" "$LINBOGRUBDIR/$I386/"
rsync -a "$EFI32_DIR/" "$LINBOGRUBDIR/$EFI32/"
rsync -a "$EFI64_DIR/" "$LINBOGRUBDIR/$EFI64/"

# copy ipxe files
cp /boot/ipxe.lkrn "$LINBOGRUBDIR"
cp /boot/ipxe.efi "$LINBOGRUBDIR"
