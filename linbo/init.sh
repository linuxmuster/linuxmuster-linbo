#!/bin/sh
# init.sh - System setup and hardware detection
# This is a busybox 1.1.3 init script
# (C) Klaus Knopper 2007
# License: GPL V2

# If you don't have a "standalone shell" busybox, enable this:
# /bin/busybox --install

# Ignore signals
trap "" 1 2 11 15

# Reset fb color mode
RESET="]R"
# ANSI COLORS
# Erase to end of line
CRE="[K"
# Clear and reset Screen
CLEAR="c"
# Normal color
NORMAL="[0;39m"
# RED: Failure or error message
RED="[1;31m"
# GREEN: Success message
GREEN="[1;32m"
# YELLOW: Descriptions
YELLOW="[1;33m"
# BLUE: System mesages
BLUE="[1;34m"
# MAGENTA: Found devices or drivers
MAGENTA="[1;35m"
# CYAN: Questions
CYAN="[1;36m"
# BOLD WHITE: Hint
WHITE="[1;37m"

CMDLINE=""

# Utilities

# DMA
enable_dma(){
 case "$CMDLINE" in *\ nodma*) return 0 ;; esac
 for d in $(cd /proc/ide 2>/dev/null && echo hd[a-z]); do
  if test -d /proc/ide/$d; then
   MODEL="$(cat /proc/ide/$d/model 2>/dev/null)"
   test -z "$MODEL" && MODEL="[GENERIC IDE DEVICE]"
   echo "${BLUE}Enabling DMA acceleration for: ${MAGENTA}$d      ${YELLOW}[${MODEL}]${NORMAL}"
   echo "using_dma:1" >/proc/ide/$d/settings
  fi
 done
}

# Setup
init_setup(){
 mount -t proc /proc /proc
 echo 0 >/proc/sys/kernel/printk
 CMDLINE="$(cat /proc/cmdline)"
 mount -t sysfs /sys /sys
 mount -t devpts /dev/pts /dev/pts 2>/dev/null
 loadkmap < /etc/german.kbd
 ifconfig lo 127.0.0.1 up
 hostname linbo
 klogd >/dev/null 2>&1
 syslogd -C 64k >/dev/null 2>&1
 # Enable CPU frequency scaling
 for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -f "$i" ] && echo "ondemand" > "$i" 2>/dev/null
 done
}

# findmodules dir
# Returns module names for modprobe
findmodules(){
 for m in `find "$@" -name \*.ko 2>/dev/null`; do
  m="${m##*/}"
  m="${m%%.ko}"
  echo "$m"
 done
}

# trycopyfromdevice device filename
trycopyfromdevice(){
 local RC=1
 local device=""
 case "$1" in /dev/*) device="$1" ;; *) device="/dev/$1" ;; esac
 if [ -b "$device" ] && mount -r "$device" /cache >/dev/null 2>&1; then
  if [ -e /cache/"$2" ]; then
   rm -f "$2"
   cp -f /cache/"$2" "$2" >/dev/null 2>&1
   RC="$?"
  fi
  umount /cache
 fi
 return "$RC"
}
 
# copyfromcache file - copies a file from cache to current dir
copyfromcache(){
 local major="" minor="" blocks="" device="" relax=""
 [ -n "$cache" ] && trycopyfromdevice "$1" && return 0
 while read major minor blocks device relax; do
   [ -n "$device" ] && trycopyfromdevice "$device" "$1" && return 0
 done < /proc/partitions
 return 1
}

# Try to read the first valid ip address from all up network interfaces
get_ipaddr(){
 local ip=""
 while read line; do
  case "$line" in *inet\ addr:*)
   ip="${line##*inet addr:}"
   ip="${ip%% *}"
   case "$ip" in 127.0.0.1) continue;; esac
   [ -n "$ip" ] && { echo "$ip"; return 0; }
   ;;
  esac
 done <<.
$(ifconfig)
.
 return 1
}

# Utilities
# get_hostname ip
get_hostname(){
 local NAME=""
 local key=""
 local value=""
 # Try dhcp info first.
 if [ -f "/tmp/dhcp.log" ]; then
  NAME="`grep ^hostname /tmp/dhcp.log | tail -1 | cut -f2 -d"'"`"
  [ -n "$NAME" ] && { echo "$NAME"; return 0; }
 fi
 # Then DNS
 if [ -n "$1" ] && grep -q ^nameserver /etc/resolv.conf; then
  while read key value relax; do
   case "$key" in
    Name:) NAME="${value%%.*}" ; break ;;
   esac
  done <<.
$(nslookup "$1" 2>/dev/null)
.
 [ -n "$NAME" ] && { echo "$NAME"; return 0; }
 fi
 return 1
}

# Get Gateway address as server.
get_server(){
 local ip=""
 local a=""
 local b=""
 # Try servername from dhcp.log first.
 if [ -f "/tmp/dhcp.log" ]; then
  ip="`grep ^serverid /tmp/dhcp.log | tail -1 | cut -f2 -d"'"`"
  [ -n "$ip" ] && { echo "$ip"; return 0; }
 fi
 # Then guess from route
 while read a b relax; do
  case "$a" in 0.0.0.0)
   ip="$b"
   [ -n "$ip" ] && { echo "$ip"; return 0; }
   ;;
  esac
 done <<.
$(route -n)
.
 return 1
}

network(){
 case "$(cat /proc/cmdline)" in *\ nonetwork|*\ localmode*)
  touch /tmp/linbo-network.done
  return 0
  ;;
 esac
 rm -f /tmp/linbo-network.done
 UNAME="$(uname -r)"
 NETMODULES="$(findmodules /lib/modules/$UNAME/kernel/drivers/net)"
 for m in $NETMODULES; do modprobe "$m" & done
 sleep 2
 if [ -n "$ipaddr" ]; then
  [ -n "$netmask" ] && nm="netmask $netmask" || nm=""
  ifconfig ${netdevice:-eth0} $ipaddr $nm
 else
  for i in /sys/class/net/*; do
   [ -d "$i" ] || continue
   dev="${i##*/}"
   case "$dev" in lo*|br*) continue;; esac
   ifconfig "$dev" up >/dev/null 2>&1
   udhcpc -n -i "$dev" >/dev/null 2>&1
  done
 fi
 # Network is up now, fetch a new start.conf
 # If server, ipaddr and cache are not set on cmdline, try to guess.
 [ -n "$ipaddr" ] || ipaddr="`get_ipaddr`"
 [ -n "$hostname" ] || hostname="`get_hostname $ipaddr`"
 [ -n "$hostname" ] && hostname "$hostname"
 [ -n "$server" ] || server="`get_server`"
 # Move away old start.conf and look for updates
 mv -f start.conf start.conf.dist
 if [ -n "$server" ]; then
  for i in "start.conf-$ipaddr" "start.conf"; do
   rsync -L "$server::linbo/$i" "start.conf" >/dev/null 2>&1 && break
  done
 fi
 if [ ! -s start.conf ]; then
  # No new version / no network available, look for a cached copy.
  while [ ! -e "/tmp/linbo-cache.done" ]; do # Wait unil harddisk is available
   sleep 1
  done
  copyfromcache start.conf
 fi
 # Still nothing new, revert to old version.
 [ -s start.conf ] || mv -f start.conf.dist start.conf
 echo > /tmp/linbo-network.done 
}

# HW Detection
hwsetup(){
 rm -f /tmp/linbo-cache.done
 UNAME="$(uname -r)"
 HDDMODULES="$(findmodules /lib/modules/$UNAME/kernel/drivers/ide /lib/modules/$UNAME/kernel/drivers/ata /lib/modules/$UNAME/kernel/drivers/usb /lib/modules/$UNAME/kernel/drivers/scsi)"
 FSMODULES="$(findmodules /lib/modules/$UNAME/kernel/fs)"
 # Silence
 for m in $HDDMODULES $FSMODULES; do modprobe "$m" & done
 sleep 1
 enable_dma
 echo > /tmp/linbo-cache.done 
}

# Main
echo "Hello, World."

# Initial setup
init_setup >/dev/null 2>&1

# BG processes (HD and Network detection can run in parallel)
hwsetup >/dev/null 2>&1 &
network >/dev/null 2>&1 &

