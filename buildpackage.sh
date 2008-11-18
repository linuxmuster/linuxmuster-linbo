#!/bin/bash

fakeroot dpkg-buildpackage \
    -tc -sa -us -uc \
    -I".svn" \
    -I".directory" \
    -Icache \
    -Isrc \
    -Ikernel \
    -Ilinbo_gui/linbo_gui \
    -Ilinbo_gui/qt-embedded* \
    -Idoc/*.pdf \
    -Idoc/*.log \
    -Idoc/*.aux \
    -Idoc/*.out \
    -Idoc/*.lof \
    -Idoc/*.toc
