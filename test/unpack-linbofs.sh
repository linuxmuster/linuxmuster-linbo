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

if [ "x$1" == "x" -o "x$2" == "x" ]; then
	echo "Error: usage $0 <sysroot> <unpackroot> (<arch>|32)!"
	exit 1
fi

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
xzcat $LINBODIR/linbofs$ARCH.lz | (cd $tmpdir; cpio -i -d -H newc --no-absolute-filenames); RC="$?"
[ "$RC" -ne 0 ] && bailout "failed!"

echo "Ok!"

