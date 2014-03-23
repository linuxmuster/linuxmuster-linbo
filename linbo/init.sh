#!/bin/sh
# init.sh - System setup and hardware detection
# This is a busybox 1.1.3 init script
# (C) Klaus Knopper 2007
# License: GPL V2
#
# thomas@linuxmuster.net
# 23.03.2014
#

# If you don't have a "standalone shell" busybox, enable this:
# /bin/busybox --install

# Ignore signals
trap "" 1 2 11 15

# Reset fb color mode
RESET="]R"
# ANSI COLORS
# Erase to end of line
CRE="
[K"
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

# test if variable is an integer
isinteger () {
 [ $# -eq 1 ] || return 1
 case $1 in
 *[!0-9]*|"") return 1;;
           *) return 0;;
 esac
}

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

# create device nodes
udev_extra_nodes() {
  grep '^[^#]' /etc/udev/links.conf | \
  while read type name arg1; do
    [ "$type" -a "$name" -a ! -e "/dev/$name" -a ! -L "/dev/$name" ] ||continue
    case "$type" in
      L) ln -s $arg1 /dev/$name ;;
      D) mkdir -p /dev/$name ;;
      M) mknod -m 600 /dev/$name $arg1 ;;
      *) echo "links.conf: unparseable line ($type $name $arg1)" ;;
    esac
  done
}

# read commandline parameters
read_cmdline(){
 mount -t proc /proc /proc
 echo 0 >/proc/sys/kernel/printk

 # parse kernel cmdline
 CMDLINE="$(cat /proc/cmdline)"
 
 case "$CMDLINE" in *\ quiet*) quiet=yes ;; esac
 case "$CMDLINE" in *\ splash*) splash=yes;; esac
}

# initial setup
init_setup(){
 case "$CMDLINE" in *\ nonetwork*|*\ localmode*) localmode=yes;; esac

 # process parameters given on kernel command line
 for i in $CMDLINE; do

  case "$i" in

   # evalutate sata_nv options
   sata_nv.swnc=*)
    value="$(echo $i | awk -F\= '{ print $2 }')"
    echo "options sata_nv swnc=$value" > /etc/modprobe.d/sata_nv.conf
   ;;

   *=*)
    eval "$i"
   ;;

  esac

 done # cmdline

 # get optionally given start.conf location
 if [ -n "$conf" ]; then
  confpart="$(echo $conf | awk -F\: '{ print $1 }')"
  extraconf="$(echo $conf | awk -F\: '{ print $2 }')"
 fi

 mount -t sysfs /sys /sys
 mount -n -o mode=0755 -t tmpfs tmpfs /dev
 if [ -e /etc/udev/links.conf ]; then
  udev_extra_nodes
 fi

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

# trycopyfromdevice device filenames
trycopyfromdevice(){
 local RC=1
 local device="$1"
 local i=""
 local files="$2"
 if ! cat /proc/mounts | grep -q "$device /cache"; then
  mount -r "$device" /cache &>/dev/null || return 1
 fi
 for i in $files; do
  if [ -e /cache/"$i" -a -s /cache/linbo ]; then
   RC=0
   cp -af /cache/"$i" . >/dev/null 2>&1
  fi
 done
 umount /cache || umount -l /cache
 return "$RC"
}

# copyfromcache file - copies a file from cache to current dir
copyfromcache(){
 local major="" minor="" blocks="" device="" relax=""
 if [ -b "$cache" ]; then
  trycopyfromdevice "$cache" "$1" && return 0
 fi
 cat /proc/partitions | grep -v ^major | while read major minor blocks device relax; do
  if [ -b "/dev/$device" ]; then
   trycopyfromdevice "/dev/$device" "$1" && return 0
  fi
 done
 return 1
}

# modify cache entry in start.conf
modify_cache(){
 [ -s "$1" ] || return 1
 if grep -qi ^cache "$1"; then
  sed -e "s|^[Cc][Aa][Cc][Hh][Ee].*|Cache = $cache|g" -i "$1"
 else
  sed -e "/^\[LINBO\]/a\
Cache = $cache" -i "$1"
 fi
}

# print cache partition
printcache(){
 local cachedev=""
 if [ -n "$cache" ]; then
  cachedev="$cache"
 else
  cachedev="$(grep -i ^cache /start.conf | tail -1 | awk -F\= '{ print $2 }' | awk '{ print $1 }' 2> /dev/null)"
 fi
 [ -b "$cachedev" ] && echo "$cachedev"
}

# copytocache file - copies start.conf to local cache
copytocache(){
 local cachedev="$(printcache)"
 case "$cachedev" in
  /dev/*) # local cache
   if ! cat /proc/mounts | grep -q "$cachedev /cache"; then
    mount "$cachedev" /cache || return 1
   fi
   if [ -s /start.conf ]; then
    echo "Saving start.conf to cache."
    cp -a /start.conf /cache
   fi
   if [ -d /icons ]; then
    echo "Saving icons to cache."
    mkdir -p /cache/icons
    rsync /icons/* /cache/icons
   fi
   # save hostname for offline use
   echo "Saving hostname $(hostname) to cache."
   hostname > /cache/hostname
   [ "$cachedev" = "$cache" ] && modify_cache /cache/start.conf
   umount /cache || umount -l /cache
   ;;
  *)
   echo "No local cache partition found!"
   return 1
   ;;
 esac
}

# copy extra start.conf given on cmdline
copyextra(){
 [ -z "$confpart" ] && return 1
 [ -z "$extraconf" ] && return 1
 mkdir -p /extra
 mount "$confpart" /extra || return 1
 local RC=1
 if [ -s "/extra$extraconf" ]; then
  cp "/extra$extraconf" /start.conf ; RC="$?"
  umount /extra || umount -l /extra
 else
  RC=1
 fi
 return "$RC"
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
    Name:)
     if [ "$1" = "$value" ]; then
      NAME="`echo ip-$value | sed 's/\./-/g'`"
     else
      NAME="${value%%.*}"
     fi
     break ;;
   esac
  done <<.
$(nslookup "$1" 2>/dev/null)
.
 [ -n "$NAME" ] && { echo "$NAME"; return 0; }
 fi
 return 1
}

# Get server address.
get_server(){
 local ip=""
 local a=""
 local b=""
 # First try servername from dhcp.log:siaddr.
 if [ -f "/tmp/dhcp.log" ]; then
  ip="`grep ^siaddr /tmp/dhcp.log | tail -1 | cut -f2 -d"'"`"
  [ -n "$ip" ] && { echo "$ip"; return 0; }
 fi
 # Second guess from route.
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

# check if reboot is set in start.conf (deprecated)
isreboot(){
 if [ -s /start.conf ]; then
  grep -i ^kernel /start.conf | awk -F= '{ print $2 }' | awk '{ print $1 }' | tr A-Z a-z | grep -q reboot && return 0
 fi
 return 1
}

# save windows activation tokens
save_winact(){
 # fetch activation status
 grep -i ^lizenzstatus: /mnt/linuxmuster-win/activation_status | grep -qi lizenziert && local activated=yes
 rm -f /mnt/linuxmuster-win/activation_status
 # if not activate yet do nothing
 [ -z "$activated" ] && return
 local mac="$(linbo_cmd mac | tr a-z A-Z)"
 # do not save if no mac address is available
 [ -z "$mac" -o "$mac" = "OFFLINE" ] && return
 # get image name
 [ -s  /mnt/.linbo ] && local image="$(cat /mnt/.linbo)"
 # if an image is not yet created do nothing
 [ -z "$image" ] && return
 # archive name contains mac address and image name
 local archive="/cache/$mac.$image.winact.tar.gz"
 # get tokens
 local tokensdat="$(ls /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Ee][Rr][Vv][Ii][Cc][Ee][Pp][Rr][Oo][Ff][Ii][Ll][Ee][Ss]/[Nn][Ee][Tt][Ww][Oo][Rr][Kk][Ss][Ee][Rr][Vv][Ii][Cc][Ee]/[Aa][Pp][Pp][Dd][Aa][Tt][Aa]/[Rr][Oo][Aa][Mm][Ii][Nn][Gg]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee][Pp][Rr][Oo][Tt][Ee][Cc][Tt][Ii][Oo][Nn][Pp][Ll][Aa][Tt][Ff][Oo][Rr][Mm]/[Tt][Oo][Kk][Ee][Nn][Ss].[Dd][Aa][Tt] 2> /dev/null)"
 [ -z "$tokensdat" ] && return
 local pkeyconfig="$(ls /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Ww][Oo][Ww]64/[Ss][Pp][Pp]/[Tt][Oo][Kk][Ee][Nn][Ss]/[Pp][Kk][Ee][Yy][Cc][Oo][Nn][Ff][Ii][Gg]/[Pp][Kk][Ee][Yy][Cc][Oo][Nn][Ff][Ii][Gg].[Xx][Rr][Mm]-[Mm][Ss] 2> /dev/null)"
 echo "Sichere Windows-Aktivierungstokens."
 tar czf "$archive" "$tokensdat" "$pkeyconfig" &> /dev/null
 if [ ! -s "$archive" ]; then
  echo "Fehler bei der Erstellung des Archivs!"
  return 1
 fi
 # do not in offline mode
 [ -e /tmp/linbo-network.done ] && return
 # trigger upload
 echo "Veranlasse Upload der Windows-Aktivierungstokens."
 rsync "$server::linbo/winact/$(basename $archive).upload" /cache &> /dev/null || true
}

# remove linbo reboot flag etc.
do_housekeeping(){
 local device="" properties="" cachedev="$(printcache)"
 sfdisk -l 2> /dev/null | grep ^/dev | grep -v Extended | grep -v "Linux swap" | while read device properties; do
  if [ "$cachedev" = "$device" ]; then
   mount "$device" /cache
   continue
  fi
  if mount "$device" /mnt 2> /dev/null; then
   if ls /mnt/.*.reboot &> /dev/null; then
    echo "Entferne Reboot-Flag von $device."
    rm -f /mnt/.*.reboot
   fi
   [ -s /mnt/linuxmuster-win/activation_status ] && save_winact
   umount /mnt
  fi
 done
 mount | grep -v grep | grep -q /cache && umount /cache
}

# handle autostart from cmdline
set_autostart() {
 # do not set autostart if linbo commands are given on command line
 [ -n "$linbocmd" ] && return 0
 # count [OS] entries
 local counts="$(grep -ci ^"\[OS\]" /start.conf)"
 # return if autostart shall be suppressed generally
 if [ "$autostart" = "0" ]; then
  echo "Disabling autostart."
  # set all autostart parameters to no
  sed -e 's|^[Aa][Uu][Tt][Oo][Ss][Tt][Aa][Rr][Tt].*|Autostart = no|g' -i /start.conf
  return
 fi
 # autostart OS at start.conf position given by autostart parameter
 local c=0
 local found=0
 local line=""
 while read -r line; do
  if echo "$line" | grep -qi ^"\[OS\]"; then
   let c++
   [ "$autostart" = "$c" ] && found=1
  fi
  # suppress autostart for other OS entries
  echo "$line" | grep -qi ^autostart || echo "$line" >> /start.conf.new
  # write autostart line for specific OS
  if [ "$found" = "1" ]; then
   echo "Enabling autostart for os nr. $c."
   echo "Autostart = yes" >> /start.conf.new
   found=0
  fi
 done </start.conf
 mv /start.conf.new /start.conf
}

network(){
 echo
 echo "Starting network configuration ..."
 if [ -n "$localmode" ]; then
  echo "Localmode configured, skipping network configuration."
  copyfromcache "start.conf icons"
  do_housekeeping
  touch /tmp/linbo-network.done
  return 0
 fi
 rm -f /tmp/linbo-network.done
 if [ -n "$ipaddr" ]; then
  echo "Using static ip address $ipaddr."
  [ -n "$netmask" ] && nm="netmask $netmask" || nm=""
  ifconfig ${netdevice:-eth0} $ipaddr $nm &> /dev/null
 else
  # iterate over ethernet interfaces
  echo "Requesting ip address per dhcp ..."
  for i in /sys/class/net/eth*; do
   dev="${i##*/}"
   ifconfig "$dev" up &> /dev/null
   # activate wol
   ethtool -s "$dev" wol g &> /dev/null
   # dhcp retries
   [ -n "$dhcpretry" ] && dhcpretry="-t $dhcpretry"
   udhcpc -n -i "$dev" $dhcpretry &> /dev/null
   # set mtu
   [ -n "$mtu" ] && ifconfig "$dev" mtu $mtu &> /dev/null
  done
 fi
 # Network is up now, fetch a new start.conf
 # If server, ipaddr and cache are not set on cmdline, try to guess.
 [ -n "$ipaddr" ] || ipaddr="`get_ipaddr`"
 [ -n "$hostname" ] || hostname="`get_hostname $ipaddr`"
 [ -n "$hostname" ] && hostname "$hostname"
 [ -n "$server" ] || server="`get_server`"
 echo "IP: $ipaddr * Hostname: $hostname * Server: $server"
 # Move away old start.conf and look for updates
 mv start.conf start.conf.dist
 if [ -n "$server" ]; then
  export server
  echo "linbo_server='$server'" >> /tmp/dhcp.log
  echo "mailhub=$server:25" > /etc/ssmtp/ssmtp.conf
  echo "Downloading configuration files from $server ..."
  for i in "start.conf-$ipaddr" "start.conf"; do
   rsync -L "$server::linbo/$i" "start.conf" &> /dev/null && break
  done
  # also look for other needed files
  for i in "torrent-client.conf" "multicast.list"; do
   rsync -L "$server::linbo/$i" "/$i" &> /dev/null
  done
  # and (optional) the GUI icons
  for i in linbo_wallpaper.png $(grep -i ^iconname /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }'); do
   rsync -L "$server::linbo/icons/$i" /icons &> /dev/null
  done
  # save downloaded stuff to cache
  copytocache
 fi
 # copy start.conf optionally given on cmdline
 copyextra && local extra=yes
 if [ ! -s start.conf ]; then
  # No new version / no network available, look for cached copies of start.conf and icons folder.
  copyfromcache "start.conf icons"
 else
  # flag for network connection
  echo "Network connection to $server successfully established."
  echo > /tmp/network.ok
 fi
 # Still nothing new, revert to old version.
 [ -s start.conf ] || mv -f start.conf.dist start.conf
 # modify cache in start.conf if cache was given and no extra start.conf was defined
 [ -z "$extra" -a -b "$cache" ] && modify_cache /start.conf
 # set autostart if given on cmdline
 isinteger "$autostart" && set_autostart
 # sets flag if no default route
 route -n | grep -q ^0\.0\.0\.0 || echo > /tmp/.offline
 # start ssh server
 echo "Starting ssh server."
 /sbin/dropbear -s -g -E -p 2222 &> /dev/null
 # remove reboot flag, save windows activation
 do_housekeeping
 # done
 echo > /tmp/linbo-network.done
 echo "Done."
 rm -f /outfifo
}

# HW Detection
hwsetup(){
 rm -f /tmp/linbo-cache.done
 echo "## Hardware-Setup - Begin ##" >> /tmp/linbo.log

 #
 # Udev starten
 echo > /sys/kernel/uevent_helper
 udevd --daemon
 mkdir -p /dev/.udev/db/ /dev/.udev/queue/
 udevadm trigger
 mkdir -p /dev/pts
 mount /dev/pts
 udevadm settle || true

 #
 # Load acpi fan and thermal modules if available, to avoid machine
 # overheating.
 modprobe fan >/dev/null 2>&1 || true
 modprobe thermal >/dev/null 2>&1 || true

 export TERM_TYPE=pts
 
 dmesg >> /tmp/linbo.log
 echo "## Hardware-Setup - End ##" >> /tmp/linbo.log

 sleep 2
 echo > /tmp/linbo-cache.done 
}

# Main
#clear
echo
echo 'Welcome to'
echo ' _        _   __     _   ____      _____'
echo '| |      | | |  \   | | |  _ \    / ___ \'
echo '| |      | | |   \  | | | | | |  / /   \ \'
echo '| |      | | | |\ \ | | | |/ /  | |     | |'
echo '| |      | | | | \ \| | | |\ \  | |     | |'
echo '| |____  | | | |  \   | | |_| |  \ \___/ /'
echo '|______| |_| |_|   \__| |____/    \_____/'
echo

# initial setup
read_cmdline
echo
echo "Configuring hardware ..."
echo
if [ -n "$quiet" ]; then
 init_setup &> /dev/null
 hwsetup &> /dev/null
else
 init_setup
 hwsetup
fi

# console mode
if [ -z  "$splash" ]; then
 network
 # execute linbo commands given on commandline
 [ -n "$linbocmd" ] && /usr/bin/linbo_wrapper $(echo "$linbocmd" | sed -e 's|,| |g')
 exit 0
fi

# splash mode

# no kernel messages, no screen blanking
setterm -msg off -cursor off -linewrap off -foreground green -blank 0 -powerdown 0
tput clear

# create pipes for progress bar and output
mkfifo /fbfifo
mkfifo /outfifo

# start fbsplash
fbsplash -i /etc/splash.conf -f /fbfifo -s /etc/splash.pnm &
fbsplash_pid="$!"

# start network and grab output
network > /outfifo &

# defaults for console output
YPOS=12
COLS=62
SEPLINE="$(for i in $(seq $COLS); do echo -n '-'; done)"
XPOS=19
MAXCOUNT=100
COUNTSTEP=12

# console output for network configuration
count=$COUNTSTEP
while read DATA; do
 tput cup $YPOS $XPOS
 printf "%${COLS}s"
 tput cup $YPOS $XPOS
 echo "$DATA"
 [ $count -gt $MAXCOUNT ] && count=$MAXCOUNT
 echo "$count" > /fbfifo
 count=$(($count + $COUNTSTEP))
done < /outfifo
echo $MAXCOUNT > /fbfifo

# wait for network
while [ ! -e /tmp/linbo-network.done ]; do
 sleep 1
done

# console output for linbo commands
if [ -n "$linbocmd" ]; then

 # start progress bar
 ( count=0; while true; do sleep 1; echo $count > /fbfifo; count=$(($count + 10)); [ $count -gt $MAXCOUNT ] && count=0; done ) &
 pb_pid="$!"

 # iterate over on commandline given linbo commands
 n=1
 for cmd in ${linbocmd//,/ }; do

  # pause between commands
  [ $n -gt 1 ] && sleep 3

  # create pipe for command output
  mkfifo /outfifo
  # filter password
  if echo "$cmd" | grep -q ^linbo:; then
   msg="linbo_wrapper linbo:*****"
  else
   msg="linbo_wrapper $cmd"
  fi
  ( echo "$msg" ; /usr/bin/linbo_wrapper "$cmd" 2>&1 ; rm /outfifo ) > /outfifo &

  # read and print output
  header=""
  while read DATA; do
   # print header once
   if [ -z "$header" ]; then
    tput cup $(($YPOS - 2)) $XPOS
    printf "%${COLS}s"
    tput cup $(($YPOS - 2)) $XPOS
    echo "${DATA:0:$COLS}"
    tput cup $(($YPOS - 1)) $XPOS
    echo "$SEPLINE"
    header=yes
   else
    tput cup $YPOS $XPOS
    printf "%${COLS}s"
    tput cup $YPOS $XPOS
    echo "${DATA:0:$COLS}"
   fi
   tput cup $YPOS $XPOS
  done < /outfifo

  n=$(( $n + 1 ))

 done
fi
echo $MAXCOUNT > /fbfifo

# kill progress bar
kill "$pb_pid"
ps w | grep -q " $pb_pid " && kill -9 "$pb_pid"

echo "exit\n" > /fbfifo
clear
setterm -default
kill "$fbsplash_pid"
rm -f /fbfifo

exit 0
