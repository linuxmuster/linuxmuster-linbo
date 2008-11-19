#!/bin/bash
#
# creating/updating group specific linbofs.gz
#
# Thomas Schmitt <schmitt@lmz-bw.de>
# 19.11.2008
#

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

# this script makes only sense if imaging=linbo
if [ "$imaging" != "linbo" ]; then
	echo "Imaging system is $imaging and not linbo!"
	exit 0
fi

# check for default linbofs.gz
if [ ! -s "$LINBODIR/linbofs.gz" ]; then
	echo "Error: $LINBODIR/linbofs.gz not found!"
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
	sophomorix-passwd --user linbo --pass $linbo_passwd &> /dev/null ; RC=$?
	if [ $RC -ne 0 ]; then
		echo "Failed to set linbo password!"
		exit 1
	fi
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

# begin to process linbofs.gz
echo "Processing LINBO groups:"

# create temp dir for linbofs content
tmpdir=/var/tmp/linbofs.$$
curdir=`pwd`
mkdir -p /var/tmp/linbofs.$$
cd $tmpdir
# unpack linbofs.gz to tmpdir
zcat $LINBODIR/linbofs.gz | cpio -i -d -H newc --no-absolute-filenames &> /dev/null ; RC=$?
[ $RC -ne 0 ] && bailout " Failed to unpack linbofs.gz!"

# begin with default linbofs.gz
echo -n "  * default ... "

# store linbo md5 password
[ -n "$linbo_md5passwd" ] && echo -n "$linbo_md5passwd" > etc/linbo_passwd

# create ssmtp.conf
mkdir -p etc/ssmtp
echo "mailhub=$serverip:25" > etc/ssmtp/ssmtp.conf

# copy default start.conf
cp -f $LINBODIR/start.conf .

# pack default linbofs.gz again
find . | cpio --quiet -o -H newc | gzip -9c > $LINBODIR/linbofs.gz ; RC="$?"
[ $RC -ne 0 ] && bailout "failed!"
echo -e "[LINBOFS]\ntimestamp=`date +%Y\%m\%d\%H\%M`\nimagesize=`ls -l $LINBODIR/linbofs.gz | awk '{print $5}'`" > $LINBODIR/linbofs.gz.info
echo "Ok!"

# now process all groups found in $WIMPORTDATA
for i in `grep -v ^# $WIMPORTDATA | awk -F\; '{ print $3 " " $11 }' | grep -v -w 0 | awk '{ print $1 }' | sort -u`; do

	# do nothing if there is no start.conf for this group
	[ -e "$LINBODIR/start.conf.$i" ] || continue

	# print group name
	echo -n "  * $i ... "

	# adding group name to start.conf
	if grep -q ^Group $LINBODIR/start.conf.$i; then
		sed -e "s/^Group.*/Group = $i/" -i $LINBODIR/start.conf.$i
	else
		sed -e "/^Server/a\
Group = $i" -i $LINBODIR/start.conf.$i
	fi

	# copy group specific start.conf
	cp -f $LINBODIR/start.conf.$i start.conf

	# pack group specific linbofs.gz
	find . | cpio --quiet -o -H newc | gzip -9c > $LINBODIR/linbofs.$i.gz ; RC=$?
	[ $RC -ne 0 ] && bailout "failed!"
	echo -e "[LINBOFS]\ntimestamp=`date +%Y\%m\%d\%H\%M`\nimagesize=`ls -l $LINBODIR/linbofs.$i.gz | awk '{print $5}'`" > $LINBODIR/linbofs.$i.gz.info
	echo "Ok!"

done

# clean tmpdir
cd $curdir
rm -rf $tmpdir

