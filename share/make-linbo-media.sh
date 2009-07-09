#!/bin/bash
#
# create linbo live media
#
# Thomas Schmitt <schmitt@lmz-bw.de>
#
# GPL V3
#
# last change: 20.03.2009
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
	echo " -d <device>             writes directly to device (optional), cann be used with -c or -u"
	echo " -g <group1,group2,...>  list of hostgroups to build for (optional, default: default)"
	echo " -i <output dir>         creates cdrom iso in output dir"
	echo " -u                      create usb media, has to be used with -d or -z"
	echo " -z <output dir>         creates zip archive with usb boot media files in output dir"
	echo
	echo " Examples:"
	echo
	echo " `basename $0` -c -i /home/administrators/administrator"
	echo "               writes a cdrom iso image for default group to administrator's home"
	echo
	echo " `basename $0` -c -i /var/linbo -g room123"
	echo "               writes a cdrom iso image for computer group room123 to /var/linbo"
	echo
	echo " `basename $0` -c -d /dev/cdrom"
	echo "               burns a cdrom directly to device /dev/cdrom"
	echo
	echo " `basename $0` -u -g room123,default -d /dev/sdc"
	echo "               writes a bootable usb media to /dev/sdc for groups room123 and default"
	echo
	echo " `basename $0` -u -z /home/teachers/zell"
	echo "               writes a zip archive with usb boot media files for default group to teacher zell's home"
	exit 1
}


# process cmdline
while getopts ":bcd:g:hi:uz:" opt; do
  case $opt in
    b)
      DEBUG=yes
      ;;
    c)
      CDROM=yes
      [ -n "$USB" ] && usage
			MEDIA=CDROM
      ;;
    u)
      USB=yes
      [ -n "$CDROM" ] && usage
			MEDIA=USB
      ;;
    d)
      DEVICE=$OPTARG
      if [ ! -e "$DEVICE" ]; then
        echo "Device $DEVICE does not exist!"
				usage
      fi
			[ -n "$ISO" ] && usage
			[ -n "$ZIP" ] && usage
			;;
    i)
      ISO=yes
			[ -n "$DEVICE" ] && usage
			[ -n "$ZIP" ] && usage
			OUTDIR=$OPTARG
      ;;
    z)
      ZIP=yes
			[ -n "$DEVICE" ] && usage
			[ -n "$ISO" ] && usage
			OUTDIR=$OPTARG
      ;;
    g)
      GRPS=$OPTARG
      ;;
    h)
      usage
			;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# check cmdline params
[ -z "$CDROM" -a -z "$USB" ] && usage
[ -z "$DEVICE" -a -z "$ISO" -a -z "$ZIP" ] && usage
if [ -n "$ZIP" -o -n "$ISO" ]; then
	if [ ! -d "$OUTDIR" ]; then
		echo "$OUTDIR does not exist!"
		usage
	fi
fi

# check groups
if [ -n "$GRPS" ]; then
	GRPS=" ${GRPS//,/ } "
	GRPS_SYS=`grep -v ^# /etc/linuxmuster/workstations | awk -F\; '{ print $3 }' | sort -u`
	for i in $GRPS; do
		if [ "$i" = "default" ]; then
			if [ -n "$GRPS_CHECKED" ]; then GRPS_CHECKED="$GRPS_CHECKED $i"; else	GRPS_CHECKED="$i"; fi
			continue
		fi
		if echo $GRPS_SYS | grep -q -w $i; then
			if [ -e "$LINBODIR/pxelinux.cfg/$i" -a -e "$LINBODIR/linbofs.$i.gz" ]; then
				if [ -n "$GRPS_CHECKED" ]; then GRPS_CHECKED="$GRPS_CHECKED $i"; else	GRPS_CHECKED="$i"; fi
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

if [ -n "$USB" ]; then
	SYSLINUXCFG=$SHAREDIR/syslinux.cfg
  BACKGRND=$SHAREDIR/linbo-usb.png
else
	SYSLINUXCFG=$SHAREDIR/isolinux.cfg
  BACKGRND=$SHAREDIR/linbo-cd.png
fi
VERSION=`grep ^Booting $LINBODIR/boot.msg | awk '{ print $3 }'`

OUTFILE="$OUTDIR/linbo_${GRPS_CHECKED// /-}_${VERSION}"
[ -n "$ISO" ] && OUTFILE="${OUTFILE}.iso"
[ -n "$ZIP" ] && OUTFILE="${OUTFILE}.usb.zip"

MNTPNT=/var/tmp/mnt.$$
CURDIR=`pwd`

# write sys/isolinux config file
writecfg() {
	local outfile=$1
	if [ "$2" = "syslinux" ]; then
		local sysdir=/boot/$2
	else
		local sysdir=/$2
	fi
	local append1
	local append2
	local RC=1
  echo "DEFAULT $sysdir/vesamenu.c32
KBDMAP $sysdir/german.kbd
PROMPT 0
TIMEOUT 300
ONTIMEOUT menu1
MENU AUTOBOOT Automatischer Start in # Sekunden...
MENU BACKGROUND $sysdir/linbo.png
MENU TABMSG [Tab]-Taste: Optionen bearbeiten
MENU TITLE LINBO $VERSION Startmenue
menu color title                1;31;40    #90ffff00 #00000000
" > $outfile

	m=1; l=1
	for i in $GRPS_CHECKED; do

		if [ "$i" = "default" ]; then LINBOFS=linbofs.gz; else LINBOFS=linbofs.$i.gz; fi

		if [ "$2" = "isolinux" ]; then
			LINBOFS_NEW=/linbof$l.gz
		else
			LINBOFS_NEW=/$LINBOFS
		fi
		l=$(($l +1))

		append1=`grep ^APPEND $LINBODIR/pxelinux.cfg/$i | tail -1 | sed -e "s|initrd=$LINBOFS|initrd=$LINBOFS_NEW|"`
		append2=`grep ^APPEND $LINBODIR/pxelinux.cfg/$i | head -1 | sed -e "s|initrd=$LINBOFS|initrd=$LINBOFS_NEW|"`

		echo "LABEL menu$m
MENU LABEL ^$m. LINBO: $i
KERNEL /linbo
$append1
" >> $outfile

		if [ -n "$DEBUG" ]; then
			echo "LABEL menu$(($m +1))
MENU LABEL ^$(($m +1)). LINBO: $i (debug)
KERNEL /linbo
$append2
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


# writing files to stick/image
writefiles() {
	if [ "$1" = "syslinux" ]; then
		local targetdir=$MNTPNT/boot/$1
	else
		local targetdir=$MNTPNT/$1
	fi
	local targetcfg=$targetdir/$1.cfg
	mkdir -p $targetdir
	writecfg $targetcfg $1
	cp $BACKGRND $targetdir/linbo.png
	cp $GERMANKBD $targetdir
	cp $REBOOTC32 $targetdir
	cp $VMENUC32 $targetdir
	cp $GPXEKRN $targetdir
	[ "$1" = "isolinux" ] && cp $ISOLINUXBIN $targetdir
	cp $LINBODIR/linbo $MNTPNT
	l=1
	for i in $GRPS_CHECKED; do
		if [ "$i" = "default" ]; then
			if [ "$1" = "isolinux" ]; then
				cp $LINBODIR/linbofs.gz $MNTPNT/linbof$l.gz
			else
				cp $LINBODIR/linbofs.gz $MNTPNT
			fi
		else
			if [ "$1" = "isolinux" ]; then
				cp $LINBODIR/linbofs.$i.gz $MNTPNT/linbof$l.gz
			else
				cp $LINBODIR/linbofs.$i.gz $MNTPNT
			fi
		fi
		l=$(($l +1))
	done
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

		echo -n "Writing files to temp dir ..."
		writefiles syslinux
		echo "Ok!"

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

  echo -n "Writing files to temp dir ..."
	writefiles isolinux
	echo "Ok!"

	MKISOFS=`which mkisofs`
	if [ -z "$MKISOFS" ]; then
		echo "mkisofs not found! Please install mkisofs!"
		rm -rf $MNTPNT
		exit 1
	fi

	echo -n "Creating iso image ... "
	cd $MNTPNT
	$MKISOFS -r -no-emul-boot -boot-load-size 4 -boot-info-table \
					-b isolinux/isolinux.bin -c isolinux/boot.cat \
					-m .svn -J -R -l -o $OUTFILE ./ ; RC=$?
	cd $CURDIR

	if [ "$RC" = "0" ]; then
		echo "Ok!"
	else
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

		if [ "$RC" = "0" ]; then
			echo "Ok!"
		else
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

echo "### Finished on `date` ###" | tee -a $LOGFILE

