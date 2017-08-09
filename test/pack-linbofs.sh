#!/bin/bash
#
# packing specific linbofs64.lz
#
# Thomas Schmitt <schmitt@lmz-bw.de>
#
# GPL V3
#
# last change: 28.11.2009
#

source /etc/sysconfig/schoolserver || exit 1

if [ "x$1" == "x" -o "x$2" == "x" ]; then
	echo "Error: usage $0 <dir#> <packroot> (<arch>|32)!"
	exit 1
fi

curdir="$(pwd)"

LINBODIR=$2

if [ "x$3" == "x" ]; then
	ARCH=
else
	ARCH=$3
fi

# sets serverip in start.conf
set_serverip(){
	local conf=$1
	grep -q ^"Server = $SCHOOL_SERVER" $conf && return 0
	if grep -q ^Server $conf; then
		sed -e "s/^Server.*/Server = $SCHOOL_SERVER/" -i $conf
	else
		sed -e "/^\[LINBO\]/a\
Server = $SCHOOL_SERVER" -i $conf
	fi
}

# clean tmpdir and exit with error
bailout() {
	echo "$1"
	cd $curdir
	exit 1
}

# begin to process linbofs(64).lz
echo "Packing LINBO fs from: $LINBODIR/linbofs$ARCH.$1 to: $LINBODIR/linbofs$ARCH.lz"

# create temp dir for linbofs64 content
tmpdir=$LINBODIR/linbofs$ARCH.$1

cd $tmpdir
# check and copy default start.conf
set_serverip $LINBODIR/start.conf
cp -f $LINBODIR/start.conf .

# pack linbofs(64).lz
find . | cpio --quiet -o -H newc | lzma -zcv > $LINBODIR/linbofs$ARCH.lz ; RC="$?"
[ "$RC" -ne 0 ] && bailout "failed!"

md5sum "$LINBODIR/linbofs$ARCH.lz"  | awk '{ print $1 }' > "$LINBODIR/linbofs$ARCH.lz.md5"

echo "Ok!"
cd $curdir
