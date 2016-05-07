#!/bin/bash

rm -f debian/files
rm -rf debian/linuxmuster-linbo

#    -tc -sn -us -uc \
dpkg-buildpackage \
    -nc \
    -I".git" \
    -I".directory" \
    -Icache \
    -Ibuild \
    -Ims-sys-* \
    -Ilinux-* -Isysroot* \
    -Intfs-3g_ntfsprogs-* \
    -IlsaSecrets-master \
    -Iparted-* \
    -Ibusybox-* \
    -Iqt-everywhere-opensource-src-* \
    -Ichntpw-* \
    -Icloop-*
