#!/bin/bash
#
# create bootable linbo isos
#
# thomas@linuxmuster.net
# 20160916
# GPL V3
#

# read linuxmuster environment
source /usr/share/linuxmuster/defaults.sh || exit 1

curdir="$(pwd)"
LINBOISO="$LINBODIR/linbo.iso"

GRUBDIR="$LINBODIR/boot/grub"
GRUBEFI32DIR="$GRUBDIR/i386-efi"
GRUBEFI64DIR="$GRUBDIR/x86_64-efi"
GRUBBIOSDIR="$GRUBDIR/i386-pc"
CORE32EFI="$GRUBEFI32DIR/core.iso"
CORE64EFI="$GRUBEFI64DIR/core.iso"

ISOCACHE="$LINBOCACHEDIR/iso"
mkdir -p "$ISOCACHE"
GRUBPREFIX="boot/grub"
GRUBBIOSTGT="$GRUBPREFIX/i386-pc"
GRUBTHEMETXT="$GRUBPREFIX/themes/linbo/theme.txt"

GRUBCFG="$LINBOTPLDIR/grub.cfg.iso"
LINBOCFG="$LINBOTPLDIR/linbo.cfg.iso"

ISOLINUXCFG="$LINBOTPLDIR/isolinux"
ISOLINUXSRC="/usr/lib/ISOLINUX"
ISOLINUXBIN="$ISOLINUXSRC/isolinux.bin"
ISOHDPFX="$ISOLINUXSRC/isohdpfx.bin"
SYSLINUXSRC="/usr/lib/syslinux/modules/bios"
SYSLINUXMODS="config ifcpu64 ldlinux libcom32 libutil vesamenu"

EFIIMGSIZE="90M"
EFIMOUNT="/var/tmp/efi.$$"
mkdir -p "$EFIMOUNT"

cd "$ISOCACHE"

# clean cache
rm -f efiboot.img
rm -rf EFI
rm -rf BOOT
rm -rf isolinux

# create iso content
mkdir -p "$GRUBPREFIX"
rsync -a -L --delete --delete-excluded --exclude=*.cfg* --exclude=spool "$GRUBDIR/" "$GRUBPREFIX/"
cp "$GRUBCFG" "$GRUBPREFIX/grub.cfg"
cp "$LINBOCFG" "$GRUBPREFIX/linbo.cfg"
for i in linbo linbo-np linbo64 linbofs.lz linbofs-np.lz linbofs64.lz linbo-version; do
 cp "$LINBODIR/$i" "$ISOCACHE"
done
sed -i 's|"LINBO Start-Menue"|"LINBO Start-Menue (EFI-Modus)"|' "$GRUBTHEMETXT"

# isolinux stuff
mkdir -p isolinux
cp "$ISOLINUXBIN" isolinux
for i in $SYSLINUXMODS; do
 cp "$SYSLINUXSRC/$i.c32" isolinux
done
cp isolinux/ldlinux.c32 .
cp "$ISOLINUXCFG"/*.cfg isolinux

# make efi boot image
dd if=/dev/zero of=efiboot.img bs=1 count=0 seek="$EFIIMGSIZE"
mkdosfs efiboot.img
mount -o loop efiboot.img "$EFIMOUNT"
mkdir -p "$EFIMOUNT/EFI/BOOT"
cp "$CORE32EFI" "$EFIMOUNT/EFI/BOOT/BOOTia32.EFI"
cp "$CORE64EFI" "$EFIMOUNT/EFI/BOOT/BOOTx64.EFI"
cp "$CORE32EFI" "$EFIMOUNT/EFI/BOOT/grubia32.efi"
cp "$CORE64EFI" "$EFIMOUNT/EFI/BOOT/grubx64.efi"
cp -r boot "$EFIMOUNT"
cp linbo* "$EFIMOUNT"
mkdir -p EFI/BOOT
cp "$EFIMOUNT/EFI/BOOT/"* EFI/BOOT/
umount "$EFIMOUNT"
rm -rf "$EFIMOUNT"

# create hybrid iso file
xorriso -as mkisofs \
  -o "$LINBOISO" \
  -isohybrid-mbr "$ISOHDPFX" \
  -c isolinux/boot.cat \
  -b isolinux/isolinux.bin \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e efiboot.img \
     -no-emul-boot \
     -isohybrid-gpt-basdat \
  .

isohybrid --uefi "$LINBOISO"
