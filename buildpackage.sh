#!/bin/bash

for i in conf debian etc examples linbo share; do
 find ${i}/ -type f -name \*~ -exec rm '{}' \;
done

rm -f debian/files
rm -rf kernel/modules

fakeroot dpkg-buildpackage \
    -tc -sn -us -uc \
    -I".git" \
    -I".directory" \
    -Icache \
    -Isrc \
    -Ikernel \
    -Ilinbo_gui/linbo_gui \
    -Ilinbo_gui/qt-*