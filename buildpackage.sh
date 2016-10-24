#!/bin/bash
#
# thomas@linuxmuster.net
# 20161022
#

for i in conf debian files graphics linbofs; do
 find ${i}/ -type f -name \*~ -exec rm '{}' \;
done

rm -f debian/files
rm -rf kernel/modules
rm -rf kernel-np/modules
rm -rf kernel64/modules

fakeroot dpkg-buildpackage \
    -tc -sn -us -uc \
    -I".git" \
    -I".directory" \
    -Icache \
    -Isrc \
    -Isrc64 \
    -Ikernel \
    -Ikernel-np \
    -Ikernel64 \
    -Ilinbo_gui/linbo_gui \
    -Ilinbo_gui/qt-* \
    -Ilinbo_gui32 \
    -Ilinbo_gui64
