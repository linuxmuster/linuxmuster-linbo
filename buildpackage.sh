#!/usr/bin/env sh

rm -f build-stamp configure-stamp
rm -rf debian/linuxmuster-linbo

dpkg-buildpackage \
    -I.git \
    -Ibuild \
    -Ibuildroot/dl
