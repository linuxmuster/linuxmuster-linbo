#!/bin/bash
#
# create linbo live media
#
# thomas@linuxmuster.net
# 05.02.2014
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
 echo " -h                      show this help"
 echo " -b                      create debug menu entries"
 echo " -c                      create cdrom media, has to be used with -d or -i"
 echo " -d <device>             writes directly to device (optional), can be used"
 echo "                         with -c or -u"
 echo " -g <group1,group2,...>  list of hostgroups to build for, optional,"
 echo "                         if -g is not given, default group is used."
 echo " -i <output dir>         creates cdrom iso in output dir"
 echo " -n                      no strict checking for linbo ssh server, allows"
 echo "                         password based logins, needs -p for root pw, optional"
 echo " -p <password>           sets local linbo admin password, is also used for"
 echo "                         root ssh login if password logins are allowed, optional"
 echo " -r                      remove server root's public ssh key"
 echo " -u                      create usb media, has to be used with -d or -z"
 echo " -t <30>                 menu timeout in seconds until linbo will boot"
 echo "                         (0 disables timeout, default is 30)."
 echo " -z <output dir>         creates zip archive with usb boot media files in"
 echo "                         output dir"
 echo
 echo " Examples:"
 echo
 echo " `basename $0` -c -i /home/administrators/administrator"
 echo "    writes a cdrom iso image for default group to administrator's home"
 echo
 echo " `basename $0` -c -i /var/linbo -g room123"
 echo "    writes a cdrom iso image for computer group room123 to /var/linbo"
 echo
 echo " `basename $0` -c -d /dev/cdrom"
 echo "    burns a cdrom directly to device /dev/cdrom"
 echo
 echo " `basename $0` -u -g room123,default -d /dev/sdc"
 echo "    writes a bootable usb media to /dev/sdc for groups room123 and default"
 echo
 echo " `basename $0` -u -z /home/teachers/zell"
 echo "    writes a zip archive with usb boot media files for default group to"
 echo "    teacher zell's home"
 exit 1
}


# process cmdline
while getopts ":bcd:g:hi:np:rt:uz:" opt; do
 case $opt in
  b) DEBUG=yes ;;
  c) CDROM=yes
     [ -n "$USB" ] && usage
     MEDIA=CDROM ;;
  d) DEVICE=$OPTARG
     if [ ! -e "$DEVICE" ]; then
      echo "Device $DEVICE does not exist!"
      usage
     fi
     [ -n "$ISO" ] && usage
     [ -n "$ZIP" ] && usage ;;
  g) GRPS=$OPTARG ;;
  h) usage ;;
  i) ISO=yes
     [ -n "$DEVICE" ] && usage
     [ -n "$ZIP" ] && usage
     OUTDIR=$OPTARG
     [ -z "$OPTARG" ] && OUTDIR=`pwd` ;;
  n) NOSTRICT=yes ;;
  p) PASSWORD=$OPTARG ;;
  r) REMKEY=yes ;;
  u) USB=yes
     [ -n "$CDROM" ] && usage
     MEDIA=USB ;;
  t) TIMEOUT=$OPTARG ;;
  z) ZIP=yes
     [ -n "$DEVICE" ] && usage
     [ -n "$ISO" ] && usage
     OUTDIR=$OPTARG
     [ -z "$OPTARG" ] && OUTDIR=`pwd` ;;
  :) echo "Option -$OPTARG requires an argument." >&2
     usage ;;
  \?) echo "Invalid option: -$OPTARG" >&2
      usage ;;
 esac
done

# check cmdline params
[ -z "$CDROM" -a -z "$USB" ] && usage
[ -z "$DEVICE" -a -z "$ISO" -a -z "$ZIP" ] && usage
[ -n "$NOSTRICT" -a -z "$PASSWORD" ] && usage
if [ -n "$ZIP" -o -n "$ISO" ]; then
 if [ ! -d "$OUTDIR" ]; then
  echo "$OUTDIR does not exist!"
  usage
 fi
fi

# timeout
[ -z "$TIMEOUT" ] && TIMEOUT=30
[ "$TIMEOUT" = "0" ] || TIMEOUT="${TIMEOUT}0"

# check groups
if [ -n "$GRPS" ]; then
 GRPS=" ${GRPS//,/ } "
 GRPS_SYS=`grep -v ^# /etc/linuxmuster/workstations | awk -F\; '{ print $3 }' | sort -u`
 for i in $GRPS; do
  if [ "$i" = "default" ]; then
   if [ -n "$GRPS_CHECKED" ]; then
    GRPS_CHECKED="$GRPS_CHECKED $i"
   else
    GRPS_CHECKED="$i"
   fi
   continue
  fi
  if echo $GRPS_SYS | grep -q -w $i; then
   if [ -e "$LINBODIR/pxelinux.cfg/$i" -a -e "$LINBODIR/start.conf.$i" ]; then
    if [ -n "$GRPS_CHECKED" ]; then
     GRPS_CHECKED="$GRPS_CHECKED $i"
    else
     GRPS_CHECKED="$i"
    fi
   fi
  fi
 done
fi

[ -z "$GRPS_CHECKED" ] && GRPS_CHECKED=default

LOGFILE=$LOGDIR/linbo/make-linbo-media.log
BINDIR=/usr/lib/linuxmuster-linbo
SHAREDIR=/usr/share/linuxmuster-linbo

GERMANKBD=$BINDIR/german.kbd
SYSLINUX=$BINDIR/syslinux
SYSLINUXEXE=$BINDIR/syslinux.exe
ISOLINUXBIN=$BINDIR/isolinux.bin
REBOOTC32=$BINDIR/reboot.c32
VMENUC32=$BINDIR/vesamenu.c32
GPXEKRN=$BINDIR/gpxe.krn
INSTALLMBR=/sbin/install-mbr
BACKGRND=$SHAREDIR/linbo_wallpaper.png

if [ -n "$USB" ]; then
 SYSLINUXCFG=$SHAREDIR/syslinux.cfg
else
 SYSLINUXCFG=$SHAREDIR/isolinux.cfg
fi
VERSION=`grep ^Booting $LINBODIR/boot.msg | awk '{ print $3 }'`

OUTFILE="$OUTDIR/linbo_${GRPS_CHECKED// /-}_${VERSION}"
[ -n "$ISO" ] && OUTFILE="${OUTFILE}.iso"
[ -n "$ZIP" ] && OUTFILE="${OUTFILE}.usb.zip"

MNTPNT=/var/tmp/mnt.$$
TMPDIR=/var/tmp/linbofs.$$
CURDIR=`pwd`
LINBOFS=linbofs.lz

# determine linbo append params from group's pxe configfile
get_append_line() {
 append_linbo=""
 append_debug=""
 local params=""
 local line=""
 local opt=""
 local val=""
 local j=""
 local found=false
 local cfg=$LINBODIR/pxelinux.cfg/$i
 local kernelfs=$(kernelfstype $i)
 if [ -e "$cfg" ]; then
  while read line; do
   opt="$(echo $line | tr A-Z a-z | awk '{ print $1 }')"
   val="$(echo $line | tr A-Z a-z | awk '{ print $2 }')"
   [ "$opt" = "kernel" -a "$val" = "linbo" ] && found=true
   [ "$opt" = "kernel" -a "$val" = "linbo64" ] && found=true
   if [ "$found" = "true" -a "$opt" = "append" ]; then
    for j in $line; do
     case $j in
      [Aa][Pp][Pp][Ee][Nn][Dd]|[Ii][Nn][Ii][Tt][Rr][Dd]*|[Qq][Uu][Ii][Ee][Tt]|[Dd][Ee][Bb][Uu][Gg]) ;;
      *) if [ -z "$params" ]; then params="$j"; else params="$params $j"; fi ;;
     esac
    done
    break
   fi
  done <$cfg
 fi
 [ "$found" = "false" ] && echo "Warning: KERNEL linbo(64) not found in pxe config for group $i, using default values."
 if [ -z "$params" ]; then
  params="vga=788"
  [ "$found" = "true" ] && echo "Warning: No LINBO parameters found in pxe config for group $i, using default values."
 fi
 append_linbo="APPEND initrd=/$i/$kernelfs $params quiet"
 append_debug="APPEND initrd=/$i/$kernelfs $params debug"
 echo "LINBO parameters for $i: $params"
}

# write sys/isolinux config file
writecfg() {
 local outfile=$1
 if [ "$2" = "syslinux" ]; then
  local sysdir=/boot/$2
 else
  local sysdir=/$2
 fi
 local RC=1

 echo "DEFAULT $sysdir/vesamenu.c32
KBDMAP $sysdir/german.kbd
PROMPT 0
TIMEOUT $TIMEOUT
ONTIMEOUT menu1
MENU AUTOBOOT Automatischer Start in # Sekunden...
MENU BACKGROUND $sysdir/linbo.png
MENU TABMSG [Tab]-Taste: Optionen bearbeiten
MENU TITLE LINBO $VERSION Startmenue
menu color title                1;31;40    #90ffff00 #00000000
" > $outfile

 m=1
 local kernel=
 for i in $GRPS_CHECKED; do
  get_append_line
  kernel=$(kerneltype $i)
  echo "LABEL menu$m
MENU LABEL ^$m. LINBO: $i
KERNEL /$kernel
$append_linbo
" >> $outfile

  if [ -n "$DEBUG" ]; then
   echo "LABEL menu$(($m +1))
MENU LABEL ^$(($m +1)). LINBO: $i (debug)
KERNEL /$kernel
$append_debug
" >> $outfile

   m=$(($m +1))
  fi

  m=$(($m +1))
 done

 echo "LABEL localboot
MENU LABEL ^$m. Von 1. Festplatte starten
localboot 0x80

LABEL pxeboot
MENU LABEL ^$(($m +1)). PXE Boot
KERNEL $sysdir/`basename $GPXEKRN`

LABEL reboot
MENU LABEL ^$(($m +2)). Neustart
KERNEL $sysdir/`basename $REBOOTC32`" >> $outfile
}

create_linbofs() {
 local RC=0
 local g=""
 # create temp dir for linbofs content
 local curdir=`pwd`
 mkdir -p /var/tmp/linbofs.$$
 cd $TMPDIR
 xzcat $LINBODIR/$LINBOFS | cpio -i -d -H newc --no-absolute-filenames &> /dev/null || exit 1
 # change passwords
 if [ -n "$PASSWORD" ]; then
  # root password
  echo "/bin/echo root:$PASSWORD | /usr/sbin/chpasswd" > passwd.sh
  chroot $TMPDIR /bin/sh /passwd.sh
  rm passwd.sh
  # md5sum of linbo password
  local linbo_md5passwd=`echo -n $PASSWORD | md5sum | awk '{ print $1 }'`
  echo -n "$linbo_md5passwd" > etc/linbo_passwd
  echo "Local password for LINBO admin changed"
 fi
 # change dropbear options
 if [ "$NOSTRICT" = "yes" ]; then
  echo "Allowing password based ssh logins."
  sed -e 's|^/sbin/dropbear .*|/sbin/dropbear -E -p 2222|' -i init.sh
 fi
 # remove server root's public ssh key
 if [ "$REMKEY" = "yes" ]; then
  echo "Removing authorized_keys."
  rm -f .ssh/authorized_keys
 fi
 for g in $GRPS_CHECKED; do
  echo -n "Creating linbofs.lz for group $g ... "
  if [ "$g" = "default" ]; then
   cp $LINBODIR/start.conf .
  else
   cp $LINBODIR/start.conf.$g start.conf || cp $LINBODIR/start.conf .
  fi
  # pack linbofs.lz
  mkdir -p $MNTPNT/$g
  find . | cpio --quiet -o -H newc | lzma -zcv > $MNTPNT/$g/linbofs.lz ; RC="$?" || exit 1
  echo "Ok!"
 done
 cd $curdir
}

# writing files to stick/image
writefiles() {
 if [ "$1" = "syslinux" ]; then
  local targetdir=$MNTPNT/boot/$1
  mkdir -p $targetdir
 else
  local targetdir=$MNTPNT/$1
  mkdir -p $targetdir
  cp $ISOLINUXBIN $targetdir
 fi
 local targetcfg=$targetdir/$1.cfg
 writecfg $targetcfg $1
 cp $BACKGRND $targetdir/linbo.png
 cp $GERMANKBD $targetdir
 cp $REBOOTC32 $targetdir
 cp $VMENUC32 $targetdir
 cp $GPXEKRN $targetdir
 cp $LINBODIR/linbo $MNTPNT
 create_linbofs
 if [ -n "$ZIP" -a "$1" = "syslinux" ]; then
  mkdir -p $MNTPNT/utils/linux
  mkdir -p $MNTPNT/utils/win32
  cp $SYSLINUX $MNTPNT/utils/linux
  cp $INSTALLMBR $MNTPNT/utils/linux
  cp $SYSLINUXEXE $MNTPNT/utils/win32
 fi
}


# creating zip archive
create_zip() {
 echo -n "Creating zip file ... "
 cd $MNTPNT
 zip -rq9 $OUTFILE * ; RC=$?
 cd $CURDIR
 rm -rf $MNTPNT
 if [ "$RC" = "0" ]; then
  echo "Ok!"
 else
  echo "Failed!"
  exit 1
 fi
}


# print header info
echo | tee -a $LOGFILE
echo "### Creating bootable LINBO media ###" | tee -a $LOGFILE
echo "### Started on `date` ###" | tee -a $LOGFILE
echo "Media: $MEDIA" | tee -a $LOGFILE
echo "Group(s): $GRPS_CHECKED" | tee -a $LOGFILE
if [ -n "$DEVICE" ]; then
 echo Device: $DEVICE | tee -a $LOGFILE
else
 echo "Output dir: $OUTDIR" | tee -a $LOGFILE
 echo "File: `basename $OUTFILE`" | tee -a $LOGFILE
fi
[ -n "$DEBUG" ] && echo "Debug: yes" | tee -a $LOGFILE
echo "Temp dir: $MNTPNT" | tee -a $LOGFILE
echo | tee -a $LOGFILE


# create mountpoint
mkdir -p $MNTPNT


# usb stuff
make_usb() {
 if [ -n "$ZIP" ]; then
  writefiles syslinux
  create_zip
 fi

 if [ -n "$DEVICE" ]; then
  PART=${DEVICE}1

  echo -n "Writing bootloader to stick ... "
  if $SYSLINUX $PART 2>> $LOGFILE 1>> $LOGFILE; then
   echo "Ok!"
  else
   echo "Failed!"
   rm -rf $MNTPNT
   exit 1
  fi

  echo -n "Mounting stick ... "
  if mount $PART $MNTPNT; then
   echo "Ok!"
  else
   echo "Failed!"
   rm -rf $MNTPNT
   exit 1
  fi

  echo -n "Writing files to stick ..."
  writefiles syslinux
  echo "Ok!"

  echo -n "Unmounting stick ... "
  umount $MNTPNT
  rm -rf $MNTPNT
  echo "Ok!"

  echo -n "Writing MBR ... "
  if install-mbr -p 1 $DEVICE 2>> $LOGFILE 1>> $LOGFILE; then
   echo "Ok!"
  else
   echo "Failed!"
   exit 1
  fi

 fi
} # make_usb


# cdrom stuff
make_cd() {
 writefiles isolinux

 MKISOFS=`which mkisofs`
 if [ -z "$MKISOFS" ]; then
  echo "mkisofs not found! Please install mkisofs!"
  rm -rf $MNTPNT
  exit 1
 fi

 echo "Creating iso image ... "
 cd $MNTPNT
 $MKISOFS -r -no-emul-boot -boot-load-size 4 -boot-info-table \
          -b isolinux/isolinux.bin -c isolinux/boot.cat \
          -m .svn -J -R -l -o $OUTFILE ./ ; RC=$?
 cd $CURDIR

 if [ "$RC" != "0" ]; then
  echo "Failed!"
  rm -f $OUTFILE
  rm -rf $MNTPNT
  exit 1
 fi

 if [ -n "$DEVICE" ]; then
  WODIM=`which wodim`
  if [ -z "$WODIM" ]; then
   echo "wodim not found! Please install wodim!"
   exit 1
  fi

  echo "Writing to cdrom ... "
  $WODIM -s dev=$DEVICE blank=fast $OUTFILE ; RC=$?

  if [ "$RC" != "0" ]; then
   echo "Failed!"
   rm -rf $MNTPNT
   exit 1
  fi

 fi
} # make_cd


# create usb image
if [ -n "$USB" ]; then
 make_usb | tee -a $LOGFILE
fi


# create cdrom media
if [ -n "$CDROM" ]; then
 make_cd | tee -a $LOGFILE
fi

[ -d "$MNTPNT" ] && rm -rf $MNTPNT
[ -d "$TMPDIR" ] && rm -rf $TMPDIR

echo "### Finished on `date` ###" | tee -a $LOGFILE

