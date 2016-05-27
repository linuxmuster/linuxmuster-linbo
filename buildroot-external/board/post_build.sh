#!/usr/bin/env bash

set -e

shopt -s extglob
rm -fv "${TARGET_DIR}"/usr/lib/fonts/!(DejaVuSans.ttf)
rm -fv "${TARGET_DIR}"/etc/dropbear
sed -i '/\/dev\/root/d' "${TARGET_DIR}"/etc/fstab
ln -sfv busybox "${TARGET_DIR}"/usr/bin/bash
