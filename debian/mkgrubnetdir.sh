#!/bin/sh
#
# creates directory structure for grub network boot
# thomas@linuxmuster.net
# 20170521
# GPL V3
#

# required modules
# common modules
GRUB_COMMON_MODULES="all_video chain configfile cpuid echo net ext2 extcmd fat gettext gfxmenu gfxterm http \
 ntfs linux loadenv minicmd net part_gpt part_msdos png progress reiserfs search terminal test tftp"

# modules needed for cd/usb boot
GRUB_ISO_MODULES="iso9660 usb"

# arch specific netboot modules
GRUB_EFI32_MODULES="$GRUB_COMMON_MODULES efi_gop efi_uga efinet"
GRUB_EFI64_MODULES="$GRUB_COMMON_MODULES efi_gop efi_uga efinet linuxefi"
#GRUB_PC_MODULES="$GRUB_COMMON_MODULES biosdisk ntldr pxe"
GRUB_I386_MODULES="$GRUB_COMMON_MODULES biosdisk ntldr pxe"

# arch specific cd/usb boot modules (grub-pc not needed, boots with syslinux)
GRUB_EFI32_ISO_MODULES="$GRUB_ISO_MODULES $GRUB_EFI32_MODULES"
GRUB_EFI64_ISO_MODULES="$GRUB_ISO_MODULES $GRUB_EFI64_MODULES"

# architectures
I386="i386-pc"
EFI32="i386-efi"
EFI64="x86_64-efi"

# dirs
NETDIR="debian/linuxmuster-linbo-common/var/linbo"
SUBDIR="/boot/grub"
I386_DIR="/usr/lib/grub/$I386"
EFI32_DIR="/usr/lib/grub/$EFI32"
EFI64_DIR="/usr/lib/grub/$EFI64"

# image files
CORE_I386="$NETDIR$SUBDIR/$I386/core"
CORE_EFI32="$NETDIR$SUBDIR/$EFI32/core"
CORE_EFI64="$NETDIR$SUBDIR/$EFI64/core"

# grub.cfg templates
GRUBCFG_TEMPLATE="files/common/usr/share/linuxmuster-linbo/templates/grub.cfg.pxe"

# fonts
FONTS="unicode"

# make cd/usb boot images (efi only)
grub-mknetdir --modules="$GRUB_EFI32_ISO_MODULES" -d "$EFI32_DIR" --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --modules="$GRUB_EFI64_ISO_MODULES" -d "$EFI64_DIR" --net-directory="$NETDIR" --subdir="$SUBDIR"
mv "$CORE_EFI32.efi" "$CORE_EFI32.iso"
mv "$CORE_EFI64.efi" "$CORE_EFI64.iso"

# make special purpose minimal netboot image for i386
grub-mknetdir --fonts="$FONTS" -d "$I386_DIR" --net-directory="$NETDIR" --subdir="$SUBDIR"
mv "$CORE_I386.0" "$CORE_I386.min"

# make standard netboot images
grub-mknetdir --fonts="$FONTS" --modules="$GRUB_I386_MODULES" -d "$I386_DIR" --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --fonts="$FONTS" --modules="$GRUB_EFI32_MODULES" -d "$EFI32_DIR" --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --fonts="$FONTS" --modules="$GRUB_EFI64_MODULES" -d "$EFI64_DIR" --net-directory="$NETDIR" --subdir="$SUBDIR"

# copy remaining files
rsync -a "$I386_DIR/" "$NETDIR$SUBDIR/$I386/"
rsync -a "$EFI32_DIR/" "$NETDIR$SUBDIR/$EFI32/"
rsync -a "$EFI64_DIR/" "$NETDIR$SUBDIR/$EFI64/"
