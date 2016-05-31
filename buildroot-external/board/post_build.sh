#!/usr/bin/env bash

set -e

shopt -s extglob
rm -fv "${TARGET_DIR}"/usr/lib/fonts/!(DejaVuSans.ttf)
rm -fv "${TARGET_DIR}"/etc/dropbear
sed -i '/\/dev\/root/d' "${TARGET_DIR}"/etc/fstab
rm -fv "${TARGET_DIR}"/usr/lib/qt/plugins/platforms/libq{minimal,offscreen}.so
