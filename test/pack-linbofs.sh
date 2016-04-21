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

if [ "x$1" == "x" -o "x$2" == "x" ]; then
	echo "Error: usage $0 <dir#> <packroot> (<arch>|32)!"
	exit 1
fi

LINBODIR=$2

if [ "x$3" == "x" ]; then
	ARCH=
else
	ARCH=$3
fi

# clean tmpdir and exit with error
bailout() {
	echo "$1"
	[ -d "$tmpdir" ] && rm -rf $tmpdir
	exit 1
}

# begin to process linbofs(64).lz
echo "Packing LINBO fs from: $LINBODIR/linbofs$ARCH.$1 to: $LINBODIR/linbofs$ARCH.lz"

# create temp dir for linbofs64 content
tmpdir=$LINBODIR/linbofs$ARCH.$1

# pack linbofs(64).lz
(cd $tmpdir; find .) | cpio --quiet -o -H newc | lzma -zcv > $LINBODIR/linbofs$ARCH.lz ; RC="$?"
[ "$RC" -ne 0 ] && bailout "failed!"

echo "Ok!"

