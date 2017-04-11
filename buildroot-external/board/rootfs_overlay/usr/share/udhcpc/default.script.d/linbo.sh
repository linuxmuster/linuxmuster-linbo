#!/bin/sh

# Setup network interface as soon as it is bound.

date >>/tmp/dhcp.log
set >>/tmp/dhcp.log

[ -n "$subnet" ] && NETMASK="netmask $subnet" || NETMASK=""

case "$1" in bound)

 if [ -n "$interface" -a -n "$ip" ]; then
  ifconfig $interface $ip $NETMASK
  if [ -n "$router" ]; then
   route add default gw $router
  fi
 fi

 if [ -n "$dns" ]; then
  for i in $dns; do
   echo "nameserver $i"
  done > /etc/resolv.conf
 fi

 ;;
esac

