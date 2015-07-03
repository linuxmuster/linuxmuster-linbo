#!/bin/sh
#
# thomas@linuxmuster.net
# GPL v3
# 04.12.2009
#
# linbo bittorrent helper script, started in a screen session by init script
#

options="$@"

while true; do
 /usr/bin/btdownloadcurses $options ; RC="$?"
 # hash check only on initial start
 options="$(echo $options | sed -e 's|--check_hashes 1|--check_hashes 0|')"
 [ "$RC" = "0" ] || exit "$RC"
done
