#!/bin/bash

rm -f debian/files
rm -rf debian/linuxmuster-linbo

#    -tc -sn -us -uc \
dpkg-buildpackage \
    -nc \
    -I".git" \
    -I".directory" \
    -Ibuild \
    -Ibuildroot/dl
