#!/bin/sh
#
# creates directory structure for grub network boot
# thomas@linuxmuster.net
# 20170512
# GPL V3
#

# required modules
# common modules
GRUB_COMMON_MODULES="all_video chain configfile cpuid echo net ext2 extcmd fat gettext gfxmenu gfxterm http \
 ntfs linux loadenv minicmd net part_gpt part_msdos png progress reiserfs search terminal test"

# modules needed for cd/usb boot
GRUB_ISO_MODULES="iso9660 usb"

# arch specific netboot modules
GRUB_EFI32_MODULES="$GRUB_COMMON_MODULES efi_gop efi_uga efinet tftp"
GRUB_EFI64_MODULES="$GRUB_COMMON_MODULES efi_gop efi_uga efinet linuxefi tftp"
#GRUB_PC_MODULES="$GRUB_COMMON_MODULES biosdisk ntldr pxe"
GRUB_PC_MODULES="$GRUB_COMMON_MODULES ntldr pxe"

# arch specific cd/usb boot modules (grub-pc not needed, boots with syslinux)
GRUB_EFI32_ISO_MODULES="$GRUB_ISO_MODULES $GRUB_EFI32_MODULES"
GRUB_EFI64_ISO_MODULES="$GRUB_ISO_MODULES $GRUB_EFI64_MODULES"

# dirs
NETDIR="debian/linuxmuster-linbo-common/var/linbo"
SUBDIR="/boot/grub"

# image files
CORE_EFI32="$NETDIR$SUBDIR/i386-efi/core"
CORE_EFI64="$NETDIR$SUBDIR/x86_64-efi/core"

# make cd/usb boot images
grub-mknetdir --modules="$GRUB_EFI32_ISO_MODULES" -d src/bin32/usr/lib/grub/i386-efi --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --modules="$GRUB_EFI64_ISO_MODULES" -d /usr/lib/grub/x86_64-efi --net-directory="$NETDIR" --subdir="$SUBDIR"

# save cd/usb boot images with different extension
mv "$CORE_EFI32.efi" "$CORE_EFI32.iso"
mv "$CORE_EFI64.efi" "$CORE_EFI64.iso"

# make netboot images
grub-mknetdir -d src/bin32/usr/lib/grub/i386-pc --net-directory="$NETDIR" --subdir="$SUBDIR"
mv "$NETDIR$SUBDIR/i386-pc/core.0" "$NETDIR$SUBDIR/i386-pc/core.min"
grub-mknetdir --modules="$GRUB_PC_MODULES" -d src/bin32/usr/lib/grub/i386-pc --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --modules="$GRUB_EFI32_MODULES" -d src/bin32/usr/lib/grub/i386-efi --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --modules="$GRUB_EFI64_MODULES" -d /usr/lib/grub/x86_64-efi --net-directory="$NETDIR" --subdir="$SUBDIR"
