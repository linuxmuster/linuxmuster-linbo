#!/usr/bin/env bash
set -e

lzma --compress --force --keep --suffix=.lz --verbose "${1}"/rootfs.cpio
