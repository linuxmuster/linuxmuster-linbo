#!/usr/bin/env bash
set -e

lzma --compress --force --keep --suffix=.lz --verbose "${1}"/rootfs.cpio
# linbo md5sum
md5sum ${1}/bzImage | cut -f1 -d" " > ${1}/bzImage.md5
