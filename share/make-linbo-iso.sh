#!/bin/bash
#
# create linbo iso file
#
# make-linbo-iso.sh start.conf
#

# check if mkisofs is installed
MKISOFS=`which mkisofs`
[ -z "$MKISOFS" ] && echo "mkisofs not found! Please install mkisofs!" && exit 1

# check for isolinux.bin
ISOLINUXBIN=/usr/lib/syslinux/isolinux.bin
[ ! -e "$ISOLINUXBIN" ] && echo "$ISOLINUXBIN not found! Please install syslinux!" && exit 1

# check for necessary linbo stuff
LINBODIR=/var/linbo
for i in $LINBODIR/linbo $LINBODIR/linbofs.gz; do
	if [ ! -e "$i" ]; then
		echo "$i not found!"
		exit 1
	fi
done

# check for start.conf parameter
if [ "$1" = "--help" ]; then
	echo "Usage: make-linbo-iso.sh [hostgroup]"
	echo "If hostgroup is omitted the builtin start.conf is used."
	exit 0
fi

# check for hostgroup's start.conf
if [ -n "$1" ]; then
	group="$1"
	startconf="$LINBODIR/start.conf.$group"
	if [ ! -e "$startconf" ]; then
		echo "$startconf not found!"
		exit 1
	fi
fi

# create group specific linbofs
if [ -n "$group" ]; then
	echo "Creating linbofs for group $group ..."
	# md5sum of linbo password goes into ramdisk
	linbo_passwd=`grep ^linbo /etc/rsyncd.secrets | awk -F\: '{ print $2 }'`
	[ -n "$linbo_passwd" ] && linbo_md5passwd=`echo -n $linbo_passwd | md5sum | awk '{ print $1 }'`
	# temp dir for ramdisk
	tmpdir=/var/tmp/linbofs.$$
	curdir=`pwd`
	mkdir -p /var/tmp/linbofs.$$
	cd $tmpdir
	zcat $LINBODIR/linbofs.gz | cpio -i -d -H newc --no-absolute-filenames &> /dev/null
	[ -n "$linbo_md5passwd" ] && echo -n "$linbo_md5passwd" > etc/linbo_passwd
	# adding group to start.conf
	if grep -q ^Group $startconf; then
		sed -e "s/^Group.*/Group = $group/" -i $startconf
	else
		sed -e "/^Server/a\
Group = $group" -i $startconf
	fi
	cp -f $startconf start.conf
	find . | cpio --quiet -o -H newc | gzip -9c > $LINBODIR/linbofs.$group.gz
	echo -e "[LINBOFS]\ntimestamp=`date +%Y\%m\%d\%H\%M`\nimagesize=`ls -l $LINBODIR/linbofs.$group.gz | awk '{print $5}'`" > $LINBODIR/linbofs.$group.gz.info
	cd $curdir
	rm -rf $tmpdir
fi

# create temporary work dir for iso
tmpdir=/var/tmp/linbo-cd.$$
mkdir -p $tmpdir

# copy needed files to cdroot
echo "Copying files to temporary directory ..."
cp -a /usr/share/linuxmuster-linbo/cd/isolinux $tmpdir
cp $ISOLINUXBIN $tmpdir/isolinux
cp $LINBODIR/linbo $tmpdir/isolinux
if [ -n "$group" ]; then
	cp $LINBODIR/linbofs.$group.gz $tmpdir/isolinux/linbofs.gz
else
	cp $LINBODIR/linbofs.gz $tmpdir/isolinux
fi

# fetch linbo version
version=`grep ^LINBO $tmpdir/isolinux/boot.msg | awk '{ print $2 }'`
version=${version#V}
if [ -n "$group" ]; then
	LINBOISO=$LINBODIR/linbo-cd_${version}.$group.iso
else
	LINBOISO=$LINBODIR/linbo-cd_${version}.iso
fi

curdir=`pwd`
cd $tmpdir

echo "Creating $LINBOISO ..."
$MKISOFS -r -no-emul-boot -boot-load-size 4 -boot-info-table \
         -b isolinux/isolinux.bin -c isolinux/boot.cat \
         -m .svn -input-charset ISO-8859-1 -o $LINBOISO ./

status=$?

cd $curdir
rm -rf $tmpdir

if [ "$status" = 0 ]; then
	echo "$LINBOISO was successfully created! :-)"
else
	echo "Failed to create $LINBOISO! :-("
fi

exit $status
