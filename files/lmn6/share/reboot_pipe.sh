#!/bin/sh
#
# reboot_pipe.sh
# thomas@linuxmuster.net
# 11.02.2016
# creates a pipe with grub reboot configuration
#

bootpart="$1"
kernel="$2"
initrd="$3"
append="$4"
grubenv_tpl="$5"
fifo="$6"

if [ -n "$kernel" ]; then
 [ "${kernel:0:1}" = "/" ] || kernel="/$kernel"
fi
if [ -n "$initrd" ]; then
 [ "${initrd:0:1}" = "/" ] || initrd="/$initrd"
fi

# fetch pid of screen process
pid="$(screen -ls | grep "(basename $fifo)" | awk -F\. '{ print $1 }' | awk '{ print $1 }')"

# write reboot config to pipe
( sed -e "s|@@bootpart@@|$bootpart|" \
      -e "s|@@kernel@@|$kernel|" \
      -e "s|@@initrd@@|$initrd|" \
      -e "s|@@append@@|$append|" "$grubenv_tpl" > "$fifo" ; rm -f "$fifo" ; kill "$pid" ) &

# add command to screen to kill it after 30 secs if pipe was not read by host
sleep 30
rm -f "$fifo"
kill "$pid"

exit 0