#!/bin/sh
#
# creates directory structure for grub network boot
# thomas@linuxmuster.net
# 20160801
# GPL V3
#

# required modules
GRUB_COMMON_MODULES="all_video chain configfile cpuid echo net ext2 extcmd fat gettext gfxmenu gfxterm http \
 iso9660 ntfs linux loadenv minicmd net part_gpt part_msdos part_plan part_sun part_sunpc png progress \
 reiserfs search terminal test usb"
GRUB_EFI32_MODULES="efi_gop efi_uga efinet tftp"
GRUB_EFI64_MODULES="efi_gop efi_uga efinet linuxefi tftp"
GRUB_PC_MODULES="biosdisk ntldr pxe"

# dirs
CURDIR="$(pwd)"
NETDIR="debian/linuxmuster-linbo/var/linbo"
SUBDIR="/boot/grub"

# make boot dirs & images
grub-mknetdir --modules="$GRUB_PC_MODULES $GRUB_COMMON_MODULES" -d src/bin32/usr/lib/grub/i386-pc --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --modules="$GRUB_EFI32_MODULES $GRUB_COMMON_MODULES" -d src/bin32/usr/lib/grub/i386-efi --net-directory="$NETDIR" --subdir="$SUBDIR"
grub-mknetdir --modules="$GRUB_EFI64_MODULES $GRUB_COMMON_MODULES" -d /usr/lib/grub/x86_64-efi --net-directory="$NETDIR" --subdir="$SUBDIR"

# create bios cdboot image
cp src/bin32/usr/lib/grub/i386-pc/*.img "$NETDIR$SUBDIR/i386-pc"
cd "$NETDIR$SUBDIR/i386-pc"
grub-mkimage -O i386-pc -d . -o core.img --prefix=/boot/grub $GRUB_PC_MODULES $GRUB_COMMON_MODULES
cat cdboot.img core.img > eltorito.img
cd "$CURDIR"
