#!/usr/bin/env bash

set -e

shopt -s extglob
rm "${TARGET_DIR}"/usr/lib/fonts/!(DejaVuSans.ttf)
