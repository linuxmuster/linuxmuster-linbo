#!/bin/sh
#
# thomas@linuxmuster.net
# 20181214
#

set -e

[ "$(id -u)" = "0" ] || SUDO="sudo"

echo "##############################################"
echo "# Installing linuxmuster-linbo build depends #"
echo "##############################################"
echo

if [ ! -e debian/control ]; then
 echo "debian/control not found!"
 exit
fi

if ! grep -q "Source: linuxmuster-linbo" debian/control; then
 echo "This is no linuxmuster-linbo source tree!"
 exit
fi

# install build depends
BUILDDEPENDS="$(LANG=C dpkg-checkbuilddeps 2>&1 | sed -e 's|dpkg-checkbuilddeps: error: Unmet build dependencies: ||' -e 's|[(][^)]*[)]||g')"
if [ -n "$BUILDDEPENDS" ]; then
  $SUDO apt update -y
  $SUDO apt install -y $BUILDDEPENDS kmod
else
  echo "Nothing to do."
fi
