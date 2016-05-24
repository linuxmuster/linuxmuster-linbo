#!/bin/bash

rm build-stamp configure-stamp
rm -rf debian/linuxmuster-linbo

#    -nc -us -uc \
dpkg-buildpackage \
    -I".directory" \
    -I.git \
    -Ibuild \
    -Ibuildroot/dl
