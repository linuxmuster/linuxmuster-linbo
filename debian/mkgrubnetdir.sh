#!/bin/sh
#
# creates directory structure for grub network boot
# thomas@linuxmuster.net
# GPL v3
# 14.09.2015
#

# required modules
GRUB_COMMON_MODULES="all_video chain configfile cpuid echo net ext2 extcmd fat gettext gfxmenu gfxterm http \
 ntfs linux loadenv minicmd net part_gpt part_msdos png progress reiserfs search terminal test"

GRUB_EFI32_MODULES="efi_gop efi_uga efinet tftp"
GRUB_EFI64_MODULES="efi_gop efi_uga efinet linuxefi tftp"

GRUB_PC_MODULES="biosdisk ntldr pxe"

grub-mknetdir --modules="$GRUB_PC_MODULES $GRUB_COMMON_MODULES" -d /usr/lib/grub/i386-pc --net-directory=debian/linuxmuster-linbo/var/linbo --subdir=/boot/grub
grub-mknetdir --modules="$GRUB_EFI32_MODULES $GRUB_COMMON_MODULES" -d src/bin32/usr/lib/grub/i386-efi --net-directory=debian/linuxmuster-linbo/var/linbo --subdir=/boot/grub
grub-mknetdir --modules="$GRUB_EFI64_MODULES $GRUB_COMMON_MODULES" -d /usr/lib/grub/x86_64-efi --net-directory=debian/linuxmuster-linbo/var/linbo --subdir=/boot/grub
