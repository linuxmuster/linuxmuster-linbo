#!/bin/bash
#
# create bootable linbo isos
#
# thomas@linuxmuster.net
# 20160724
# GPL V3
#

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

curdir="$(pwd)"
ISODIR="$LINBODIR/isos"
mkdir -p "$ISODIR"

GRUBDIR="$LINBODIR/boot/grub"
GRUB_EFI32_DIR="$GRUBDIR/i386-efi"
GRUB_EFI64_DIR="$GRUBDIR/x86_64-efi"
GRUB_BIOS_DIR="$GRUBDIR/i386-pc"

ISOCACHE="/var/cache/linuxmuster-linbo/iso"
mkdir -p "$ISOCACHE"
ISOGRUBDIR="$ISOCACHE/boot/grub"
mkdir -p "$ISOGRUBDIR"

TPLDIR="$LINBOSHAREDIR/templates"
GRUBCFG="$TPLDIR/grub.cfg.iso"
LINBOCFG="$TPLDIR/linbo.cfg.iso"

ISOHDPFX="/usr/lib/syslinux/isohdpfx.bin"

# make efi boot images
mkefi_img(){
 cd "$1" || exit 1
 [ -s core.efi ] || exit 1
 if file core.efi | grep -q x86-64; then
  local bits=64
 else
  local bits=32
 fi
 local s=$(ls -l core.efi | awk '{ print $5 }')
 local i=$(( 4 * $s / 1024 / 1024 ))
 dd if=/dev/zero of=efi.img bs=1 count=0 seek=${i}M
 mkdosfs efi.img
 local m="/var/tmp/efi.$$"
 mkdir -p "$m"
 mount -o loop efi.img "$m"
 mkdir -p "$m/EFI/BOOT"
 cp core.efi "$m/EFI/BOOT/grubx${bits}.efi"
 cp core.efi "$m/EFI/BOOT/BOOTX${bits}.efi"
 umount "$m"
 rm -rf "$m"
}

# i386-efi
mkefi_img "$GRUB_EFI32_DIR"

# x86_64-efi
mkefi_img "$GRUB_EFI64_DIR"

# create iso content
rsync -a -L --delete --delete-excluded --exclude=spool "$GRUBDIR/" "$ISOGRUBDIR/"
cp "$GRUBCFG" "$ISOGRUBDIR/grub.cfg"
cp "$LINBOCFG" "$ISOGRUBDIR/linbo.cfg"
for i in linbo linbo-np linbo64 linbofs.lz linbofs-np.lz linbofs64.lz linbo-version; do
 cp "$LINBODIR/$i" "$ISOCACHE"
done

# create hybrid iso files
cd "$ISOCACHE"

# 32bit
xorriso -as mkisofs \
  -b boot/grub/i386-pc/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -isohybrid-mbr "$ISOHDPFX" \
  -eltorito-alt-boot \
  -e boot/grub/i386-efi/efi.img \
  -no-emul-boot \
  -o "$ISODIR/linbo32.iso" \
  .

# 64bit
xorriso -as mkisofs \
  -b boot/grub/i386-pc/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -isohybrid-mbr "$ISOHDPFX" \
  -eltorito-alt-boot \
  -e boot/grub/x86_64-efi/efi.img \
  -no-emul-boot \
  -o "$ISODIR/linbo64.iso" \
  .
