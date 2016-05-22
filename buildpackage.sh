#!/bin/bash

rm build-stamp configure-stamp
#rm -f debian/files
rm -rf debian/linuxmuster-linbo

#    -nc \
dpkg-buildpackage \
    -nc -tc -us -uc \
    -I".directory" \
    -Ibuild \
    -Ibuildroot/dl
