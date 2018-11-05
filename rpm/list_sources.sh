#!/bin/bash
# extract all download sources to be listed in the spec file
#
# Copyright Frank Schütte 2016 <fschuett@gymhim.de>
#
# GPL v3.0+
#

DOWNLOADS=$(find . -maxdepth 1 -name '*.gz' -or -name '*.bz2' -or -name '*.tgz' -or -name '*.zip' -or -name '*.xz' -or -name '*.patch'|grep -v oss-linbo |sort)

let num=1

for f in $DOWNLOADS; do
  f=${f#./}
  echo "Source${num}:	$f"
  (( num = num + 1 ))
done

exit 0
