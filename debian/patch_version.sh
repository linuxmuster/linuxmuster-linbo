#!/bin/bash
#
# patches packages version into bootscreens

# fetch version from changelog
version=`head -n 1 debian/changelog | awk -F\( '{ print $2 }' | awk -F\) '{ print $1 }'`

sed -e "s/@@version@@/$version/" debian/boot.msg.template > "debian/linuxmuster-linbo/var/linbo/boot.msg"

sed -e "s/@@version@@/$version/" debian/boot.msg.template > "debian/linuxmuster-linbo/usr/share/linuxmuster-linbo/cd/isolinux/boot.msg"
