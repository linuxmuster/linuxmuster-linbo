#!/bin/sh

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
BUILDDEPENDS="$(grep ^Build-Depend debian/control | awk -F\: '{ print $2 }' | sed -e 's|,||g')"
$SUDO apt update -y
$SUDO apt install -y $BUILDDEPENDS
