#!/bin/bash
#
# create linbo live media
#
# tschmitt@linuxmuster.net
# 03.07.2013
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
 echo
 echo " -g <group1,group2,...>  list of hostgroups to build for, optional, if -g is not"
 echo "                         given, default group is used. To process all groups"
 echo "                         give \"all\" as argument."
 echo
 echo " -o <output dir>         creates cdrom iso in output dir, defaults to $LINBODIR."
 echo
 echo " -n                      no strict checking for linbo ssh server, allows"
 echo "                         password based logins, needs -p for root pw, optional."
 echo
 echo " -p <password>           sets local linbo admin password, is also used for"
 echo "                         root ssh login if password logins are allowed, optional."
 echo
 echo " -r                      remove server root's public ssh key, needs -n to be set."
 echo
 echo " -t <n>                  menu timeout in seconds until linbo will boot"
 echo "                         (0 disables timeout, default is 30)."
 echo
 echo " -v <n>                  vga kernel parameter in integer decimal value (default 788)."
 echo
 echo " Examples:"
 echo
 echo " `basename $0` -o /home/administrators/administrator"
 echo "    writes a cdrom iso image for default group to administrator's home."
 echo
 echo " `basename $0` -g room123"
 echo "    writes a cdrom iso image for computer group room123 to /var/linbo."
 echo
 echo " `basename $0` -o /home/teachers/zell -n -r -p muster"
 echo "    writes a cdrom iso image for default group to teacher zell's home,"
 echo "    removes root's public ssh key, allows ssh password logins and sets"
 echo "    root password to muster."
 echo
 exit 1
}


# process cmdline
while getopts ":g:hno:p:rt:v:" opt; do
 case $opt in
  g) GRPS="$OPTARG" ;;
  h) usage ;;
  n) NOSTRICT=yes ;;
  p) PASSWORD="$OPTARG"
     [ -z "$PASSWORD" ] && usage ;;
  o) OUTDIR="$OPTARG" ;;
  r) REMKEY=yes ;;
  t) TIMEOUT="$OPTARG" ;;
  v) VGA="$OPTARG" ;;
  \?) echo "Invalid option: -$OPTARG" >&2
      usage ;;
 esac
done

# check cmdline params
[ -n "$NOSTRICT" -a -z "$PASSWORD" ] && usage
[ -z "$NOSTRICT" -a -n "$REMKEY" ] && usage

# vga
if [ -z "$VGA" ]; then
 VGA="788"
else
 isinteger "$VGA" || usage
fi

# outdir
[ -z "$OUTDIR" ] && OUTDIR="$LINBODIR"
[ -d "$OUTDIR" ] || usage

# timeout
if [ -n "$TIMEOUT" ]; then
 isinteger "$TIMEOUT" || usage
else
 TIMEOUT="30"
fi
[ "$TIMEOUT" = "0" ] || TIMEOUT="${TIMEOUT}0"

# check groups
if [ -n "$GRPS" ]; then
 # get all groups, filter out non pxe hosts
 GRPS_SYS="$(grep -v ^# $WIMPORTDATA | awk -F\; '{ print $3 " " $11 }' | sort -u | grep -v " 0" | awk '{ print $1 }' | tr A-Z a-z)"
 GRPS="$(echo "$GRPS" | tr A-Z a-z)"
 if [ "$GRPS" = "all" ]; then
  GRPS_CHECKED="default $GRPS_SYS"
 else
  GRPS=" ${GRPS//,/ } "
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
    if [ -e "$LINBODIR/grub/${i}.pxe" -a -e "$LINBODIR/start.conf.$i" ]; then
     if [ -n "$GRPS_CHECKED" ]; then
      GRPS_CHECKED="$GRPS_CHECKED $i"
     else
      GRPS_CHECKED="$i"
     fi
    fi
   fi
  done
 fi
fi

[ -z "$GRPS_CHECKED" ] && GRPS_CHECKED=default

LOGFILE=$LOGDIR/linbo/make-linbo-media.log
SYSLINUXDIST=/usr/lib/syslinux

GERMANKBD=$LINBOSHAREDIR/german.kbd
SYSLINUX=/usr/bin/syslinux
ISOLINUXBIN=$SYSLINUXDIST/isolinux.bin
REBOOTC32=$SYSLINUXDIST/reboot.c32
VMENUC32=$SYSLINUXDIST/vesamenu.c32
SYSLINUXCFG=$LINBOSHAREDIR/isolinux.cfg
BACKGRND=$LINBOSHAREDIR/linbo_wallpaper.png
VERSION="$(cat $LINBODIR/version)"
if [ "$GRPS" = "all" ]; then
 OUTFILE="$OUTDIR/linbo_${GRPS}_${VERSION}.iso"
else
 OUTFILE="$OUTDIR/linbo_${GRPS_CHECKED// /-}_${VERSION}.iso"
fi

MNTPNT=/var/tmp/mnt.$$
TMPDIR=/var/tmp/linbofs.$$
CURDIR=`pwd`
LINBOFS=linbofs.gz

# determine linbo append params from group's pxe configfile
get_append_line() {
 append_linbo=""
 local params=""
 local line=""
 local opt=""
 local val=""
 local j=""
 local found=false
 if [ "$i" = "default" ]; then
  local cfg=$LINBODIR/grub/grub.cfg
 else
  local cfg=$LINBODIR/grub/${i}.pxe
 fi
 params="$(grep "linux " "$cfg" | grep "/linbo " | sed "s|linux ||g" | sed "s|/linbo ||g" | sed "s|initrd=linbofs.gz||g" | head -1)"
 echo "$params" | grep -q vga || params="$params vga=$VGA"
 append_linbo="APPEND $params"
 echo "LINBO parameters for $i: $params"
}

# write sys/isolinux config file
writecfg() {
 local outfile=$1
 local sysdir=/isolinux
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
 for i in $GRPS_CHECKED; do
  get_append_line
  echo "LABEL menu$m
MENU LABEL ^$m. LINBO: $i
KERNEL /linbo
INITRD /$i/linbofs.gz
$append_linbo
" >> $outfile

  m=$(($m +1))
 done

 echo "LABEL localboot
MENU LABEL ^$m. Von 1. Festplatte starten
localboot 0x80

LABEL reboot
MENU LABEL ^$(($m +1)). Neustart
KERNEL $sysdir/`basename $REBOOTC32`" >> $outfile
}

create_linbofs() {
 local RC=0
 local g=""
 # create temp dir for linbofs content
 local curdir=`pwd`
 mkdir -p /var/tmp/linbofs.$$
 cd $TMPDIR
 zcat $LINBODIR/$LINBOFS | cpio -i -d -H newc --no-absolute-filenames &> /dev/null || exit 1
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
  echo -n "Creating linbofs.gz for group $g ... "
  if [ "$g" = "default" ]; then
   cp $LINBODIR/start.conf .
  else
   cp $LINBODIR/start.conf.$g start.conf || cp $LINBODIR/start.conf .
  fi
  # pack linbofs.gz
  mkdir -p $MNTPNT/$g
  find . | cpio --quiet -o -H newc | gzip -9c > $MNTPNT/$g/linbofs.gz ; RC="$?" || exit 1
  echo "Ok!"
 done
 cd $curdir
}

# writing files to stick/image
writefiles() {
 local targetdir=$MNTPNT/isolinux
 mkdir -p $targetdir
 cp $ISOLINUXBIN $targetdir
 local targetcfg=$targetdir/isolinux.cfg
 writecfg $targetcfg
 cp $BACKGRND $targetdir/linbo.png
 cp $GERMANKBD $targetdir
 cp $REBOOTC32 $targetdir
 cp $VMENUC32 $targetdir
 cp $LINBODIR/linbo $MNTPNT
 create_linbofs
}


# print header info
echo | tee -a $LOGFILE
echo "### Creating bootable LINBO media ###" | tee -a $LOGFILE
echo "### Started on `date` ###" | tee -a $LOGFILE
echo "Media: ISO" | tee -a $LOGFILE
echo "Group(s): $GRPS_CHECKED" | tee -a $LOGFILE
echo "Output dir: $OUTDIR" | tee -a $LOGFILE
echo "File: `basename $OUTFILE`" | tee -a $LOGFILE
echo "Temp dir: $MNTPNT" | tee -a $LOGFILE
echo | tee -a $LOGFILE


# create mountpoint
mkdir -p $MNTPNT


# cdrom stuff
make_cd() {
 writefiles

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
} # make_cd


# create cdrom media
make_cd | tee -a $LOGFILE

[ -d "$MNTPNT" ] && rm -rf $MNTPNT
[ -d "$TMPDIR" ] && rm -rf $TMPDIR

echo "### Finished on `date` ###" | tee -a $LOGFILE

