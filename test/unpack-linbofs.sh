#!/bin/bash
#
# unpacking linbofs64.lz
#
# Thomas Schmitt <schmitt@lmz-bw.de>
#
# GPL V3
#
# last change: 28.11.2009
#

source /etc/sysconfig/schoolserver || exit 1

if [ "x$1" == "x" -o "x$2" == "x" ]; then
	echo "Error: usage $0 <sysroot> <unpackroot> (<arch>|32)!"
	exit 1
fi
curdir="$(pwd)"

LINBODIR=$1

DESTDIR=$2

if [ "x$3" == "x" ]; then
	ARCH=
else
	ARCH=$3
fi

# check for linbofs(64).lz
if [ ! -s "$LINBODIR/linbofs$ARCH.lz" ]; then
	echo "Error: $LINBODIR/linbofs$ARCH.lz not found!"
	exit 1
fi

# grep linbo rsync password to sync it with linbo account
if [ ! -s /etc/rsyncd.secrets ]; then
	echo "/etc/rsyncd.secrets not found!"
	exit 1
fi
linbo_passwd=`grep ^linbo /etc/rsyncd.secrets | awk -F\: '{ print $2 }'`
if [ -z "$linbo_passwd" ]; then
	echo "Cannot read linbo password from /etc/rsyncd.secrets!"
	exit 1
else
	# md5sum of linbo password goes into ramdisk
	linbo_md5passwd=`echo -n $linbo_passwd | md5sum | awk '{ print $1 }'`
fi

# clean tmpdir and exit with error
bailout() {
	echo "$1"
	cd $curdir
	[ -d "$tmpdir" ] && rm -rf $tmpdir
	exit 1
}

# begin to process linbofs64.lz
echo "Unpacking LINBO fs to: $DESTDIR/linbofs$ARCH.$$"

# create temp dir for linbofs(64) content
tmpdir=$DESTDIR/linbofs$ARCH.$$

mkdir -p $DESTDIR/linbofs$ARCH.$$

# unpack linbofs(64).lz to tmpdir
cd $tmpdir
xzcat $LINBODIR/linbofs$ARCH.lz | cpio -i -d -H newc --no-absolute-filenames; RC="$?"
[ "$RC" -ne 0 ] && bailout "failed!"

# store linbo md5 password
[ -n "$linbo_md5passwd" ] && echo -n "$linbo_md5passwd" > etc/linbo_passwd

# create ssmtp.conf
mkdir -p etc/ssmtp
echo "mailhub=$SCHOOL_SERVER:25" > etc/ssmtp/ssmtp.conf

# provide dropbear ssh host key
mkdir -p etc/dropbear
cp /etc/linbo/dropbear_*_host_key etc/dropbear
mkdir -p etc/ssh
cp /etc/linbo/ssh_host_{ecd,d,r}sa_key* etc/ssh
mkdir -p /root/.ssh
cat /root/.ssh/id_{ec,}dsa.pub >/root/.ssh/authorized_keys
mkdir -p var/log
touch var/log/lastlog

# provide default start.conf
cp /etc/linbo/start.conf.default start.conf

echo "Ok!"
cd $curdir
