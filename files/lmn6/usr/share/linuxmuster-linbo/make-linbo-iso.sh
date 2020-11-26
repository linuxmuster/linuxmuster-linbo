#!/bin/bash
#
# create bootable linbo isos
#
# thomas@linuxmuster.net
# 20201124
# GPL V3
#

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

# usage info
usage(){
 echo
 echo "Usage: `basename $0` <options>"
 echo
 echo "Options:"
 echo
 echo " -h              Show this help."
 echo " -t <integer>    Menu timeout in seconds (default 10)."
 echo " -d <integer>    Number of default menu entry (default 0, maximal 3)."
 echo " -i <string>     Path to isofile (default /var/linbo/linbo.iso)."
 exit 1
}

# process cmdline
while getopts ":hd:i:n:t:" opt; do
  case $opt in
    d) DEFAULT="$OPTARG"
       if ! isinteger $DEFAULT; then
         echo "Value for default is not integer!"
         usage
       fi
       if [ $DEFAULT -gt 3 ]; then
         echo "Value for default is to high!"
         usage
       fi
       ;;
    i) LINBOISO="$OPTARG"
       if [ ! -d "$(dirname "$LINBOISO")" ]; then
         echo "Directory for $LINBOISO does not exist!"
         usage
       fi
       ;;
    t) TIMEOUT="$OPTARG"
       if ! isinteger $TIMEOUT; then
         echo "Value for timeout is not integer!"
         usage
       fi
       ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2
       usage ;;
  esac
done

curdir="$(pwd)"
[ -z "$LINBOISO" ] && LINBOISO="$LINBODIR/linbo.iso"

GRUBDIR="$LINBODIR/boot/grub"
GRUBEFI32DIR="$GRUBDIR/i386-efi"
GRUBEFI64DIR="$GRUBDIR/x86_64-efi"
GRUBBIOSDIR="$GRUBDIR/i386-pc"
CORE32EFI="$GRUBEFI32DIR/core.iso"
CORE64EFI="$GRUBEFI64DIR/core.iso"
IPXEBIOS="$GRUBDIR/ipxe.lkrn"
IPXEEFI="$GRUBDIR/ipxe.efi"

ISOCACHE="/var/cache/linuxmuster-linbo/iso"
mkdir -p "$ISOCACHE"
GRUBPREFIX="boot/grub"
GRUBBIOSTGT="$GRUBPREFIX/i386-pc"
GRUBTHEMETXT="$GRUBPREFIX/themes/linbo/theme.txt"

TPLDIR="$LINBOSHAREDIR/templates"
GRUBCFG="$TPLDIR/grub.cfg.iso"
LINBOCFG="$TPLDIR/linbo.cfg.iso"

ISOLINUXCFG="$TPLDIR/isolinux"
ISOLINUXSRC="/usr/lib/ISOLINUX"
ISOLINUXBIN="$ISOLINUXSRC/isolinux.bin"
ISOHDPFX="$ISOLINUXSRC/isohdpfx.bin"
SYSLINUXSRC="/usr/lib/syslinux/modules/bios"
SYSLINUXMODS="config ifcpu64 ldlinux libcom32 libutil vesamenu"

EFIIMGSIZE="128M"
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
if [ -n "$DEFAULT" ]; then
  sed -i "s|^set default=.*|set default=$DEFAULT|" "$GRUBPREFIX/linbo.cfg"
fi
if [ -n "$TIMEOUT" ]; then
  sed -i "s|^set timeout=.*|set timeout=$TIMEOUT|" "$GRUBPREFIX/linbo.cfg"
fi
for i in linbo linbo-np linbo64 linbofs.lz linbofs-np.lz linbofs64.lz linbo_gui32.tar.lz linbo_gui64.tar.lz linbo-version; do
 cp "$LINBODIR/$i" "$ISOCACHE"
done
cp "$IPXEBIOS" "$ISOCACHE"
cp "$IPXEEFI" "$ISOCACHE"
sed -i 's|"LINBO Start-Menue"|"LINBO Start-Menue (EFI-Modus)"|' "$GRUBTHEMETXT"

# isolinux stuff
mkdir -p isolinux
cp "$ISOLINUXBIN" isolinux
for i in $SYSLINUXMODS; do
 cp "$SYSLINUXSRC/$i.c32" isolinux
done
cp isolinux/ldlinux.c32 .
cp "$ISOLINUXCFG"/*.cfg isolinux
if [ -n "$DEFAULT" ]; then
  case "$DEFAULT" in
    0) LABEL="linbo" ;;
    1) LABEL="install" ;;
    2) LABEL="debug" ;;
    3) LABEL="pxe" ;;
    *) LABEL="linbo" ;;
  esac
  for i in nonpae sys32 sys64; do
    sed -i "s|^default .*| default $LABEL|" "isolinux/$i.cfg"
  done
fi
if [ -n "$TIMEOUT" ]; then
  TIMEOUT=$(( $TIMEOUT * 10 ))
  sed -i "s|^timeout .*|timeout $TIMEOUT|" isolinux/menu.cfg
fi

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
