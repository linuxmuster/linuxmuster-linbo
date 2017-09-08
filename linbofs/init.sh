#!/bin/sh
# init.sh - System setup and hardware detection
# This is a busybox 1.1.3 init script
# (C) Klaus Knopper 2007
# License: GPL V2
#
# thomas@linuxmuster.net
# 20170908
#

# If you don't have a "standalone shell" busybox, enable this:
# /bin/busybox --install

# Ignore signals
trap "" 1 2 11 15

# set terminal
export TERM=xterm

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
 case "$CMDLINE" in *\ noauto*) noauto=yes;; esac
 case "$CMDLINE" in *\ nobuttons*) nobuttons=yes;; esac
 case "$CMDLINE" in *\ localboot*) localboot=yes;; esac
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
 mount -t devtmpfs devtmpfs /dev
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
  if [ -e /cache/"$i" ] && [ -s /cache/linbo -o -s /cache/linbo64 ]; then
   RC=0
   cp -af /cache/"$i" . >/dev/null 2>&1
  fi
 done
 umount /cache || umount -l /cache
 return "$RC"
}

# copyfromcache file - copies a file from cache to current dir
copyfromcache(){
 local cachdev="$(printcache)"
 if [ -b "$cachedev" ]; then
  trycopyfromdevice "$cachedev" "$1" && return 0
 fi
 local major="" minor="" blocks="" device="" relax=""
 grep -v ^major /proc/partitions | while read -r major minor blocks device relax; do
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
 if [ -n "$cache" -a -b "$cache" ]; then
  echo "$cache"
  return 0
 fi
 [ -s /start.conf ] || return 1
 local cachedev="$(grep -i ^cache /start.conf | tail -1 | awk -F\= '{ print $2 }' | awk '{ print $1 }' 2> /dev/null)"
 if [ -n "$cachedev" -a -b "$cachedev" ]; then
  echo "$cachedev"
  return 0
 fi
 return 1
}

# copytocache file - copies start.conf to local cache
copytocache(){
 local cachedev="$(printcache)"
 [ -b "$cachedev" ] || return 1
 case "$cachedev" in
  /dev/*) # local cache
   if ! cat /proc/mounts | grep -q "$cachedev /cache"; then
    mount "$cachedev" /cache || return 1
   fi
   if [ -s /start.conf ]; then
    echo "Speichere start.conf auf Cache."
    cp -a /start.conf /cache
   fi
   if [ -d /icons ]; then
    echo "Speichere Icons auf Cache."
    mkdir -p /cache/icons
    rsync /icons/* /cache/icons
   fi
   # save hostname for offline use
   echo "Speichere Hostnamen $(hostname) auf Cache."
   hostname > /cache/hostname
   # deprecated
   #[ "$cachedev" = "$cache" ] && modify_cache /cache/start.conf
   umount /cache || umount -l /cache
   ;;
  *)
   echo "Keine lokale Cache-Partition gefunden!"
   return 1
   ;;
 esac
}

# copy extra start.conf given on cmdline
copyextra(){
 [ -b "$confpart" ] || return 1
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
 local line
 ifconfig | while read line; do
  case "$line" in *inet\ addr:*)
   ip="${line##*inet addr:}"
   ip="${ip%% *}"
   case "$ip" in 127.0.0.1) continue;; esac
   [ -n "$ip" ] && { echo "$ip"; return 0; }
   ;;
  esac
 done
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

# save windows activation tokens
save_winact(){
 # rename obsolete activation status file
 [ -e /mnt/linuxmuster-win/activation_status ] && mv /mnt/linuxmuster-win/activation_status /mnt/linuxmuster-win/win_activation_status
 # get windows activation status
 if [ -e /mnt/linuxmuster-win/win_activation_status ]; then
  grep -i ^li[cz]en /mnt/linuxmuster-win/win_activation_status | grep -i status | grep -i li[cz]en[sz][ei][de] | grep -vqi not && local win_activated="yes"
 fi
 if [ -n "$win_activated" ]; then
  echo "Windows ist aktiviert."
 else
  echo "Windows ist nicht aktiviert."
 fi
 # get msoffice activation status
 if [ -e /mnt/linuxmuster-win/office_activation_status ]; then
  grep -i ^li[cz]en /mnt/linuxmuster-win/office_activation_status | grep -i status | grep -i li[cz]en[sz][ei][de] | grep -vqi not && office_activated="yes"
 fi
 if [ -n "$office_activated" ]; then
  echo "MS Office ist aktiviert."
 else
  echo "MS Office ist nicht aktiviert oder nicht installiert."
 fi
 # remove activation status files
 rm -f /mnt/linuxmuster-win/*activation_status
 # get activation token files
 if [ -n "$win_activated" ]; then
   local windir="$(ls -d /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss])"
   # find all windows tokens and key files in windir (version independent)
   local win_tokens="$(find "$windir" -iname tokens.dat)"
   [ "$win_tokens" = "" ] || win_tokens="$win_tokens $(find "$windir" -iname pkeyconfig.xrm-ms)"
  #local win_tokensdat="$(ls /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Ee][Rr][Vv][Ii][Cc][Ee][Pp][Rr][Oo][Ff][Ii][Ll][Ee][Ss]/[Nn][Ee][Tt][Ww][Oo][Rr][Kk][Ss][Ee][Rr][Vv][Ii][Cc][Ee]/[Aa][Pp][Pp][Dd][Aa][Tt][Aa]/[Rr][Oo][Aa][Mm][Ii][Nn][Gg]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee][Pp][Rr][Oo][Tt][Ee][Cc][Tt][Ii][Oo][Nn][Pp][Ll][Aa][Tt][Ff][Oo][Rr][Mm]/[Tt][Oo][Kk][Ee][Nn][Ss].[Dd][Aa][Tt] 2> /dev/null)"
  #local win_pkeyconfig="$(ls /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Ww][Oo][Ww]64/[Ss][Pp][Pp]/[Tt][Oo][Kk][Ee][Nn][Ss]/[Pp][Kk][Ee][Yy][Cc][Oo][Nn][Ff][Ii][Gg]/[Pp][Kk][Ee][Yy][Cc][Oo][Nn][Ff][Ii][Gg].[Xx][Rr][Mm]-[Mm][Ss] 2> /dev/null)"
 fi
 [ -n "$office_activated" ] && local office_tokens="$(ls /mnt/[Pp][Rr][Oo][Gg][Rr][Aa][Mm][Dd][Aa][Tt][Aa]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]/[Oo][Ff][Ff][Ii][Cc][Ee][Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee][Pp][Rr][Oo][Tt][Ee][Cc][Tt][Ii][Oo][Nn][Pp][Ll][Aa][Tt][Ff][Oo][Rr][Mm]/[Tt][Oo][Kk][Ee][Nn][Ss].[Dd][Aa][Tt] 2> /dev/null)"
 # test if files exist
 if [ -n "$win_activated" -a -z "$win_tokens" ]; then
  echo "Keine Windows-Aktivierungsdateien vorhanden."
  win_activated=""
 fi
 if [ -n "$office_activated" -a -z "$office_tokens" ]; then
  echo "Office-Aktivierungsdatei nicht vorhanden."
  office_activated=""
 fi
 # if no activation return
 [ -z "$win_activated" -a -z "$office_activated" ] && return
 # get local mac address
 local mac="$(linbo_cmd mac | tr a-z A-Z)"
 # do not save if no mac address is available
 if [ -z "$mac" -o "$mac" = "OFFLINE" ]; then
  echo "Kann MAC-Adresse nicht bestimmen."
  return
 fi
 # get image name
 [ -s  /mnt/.linbo ] && local image="$(cat /mnt/.linbo)"
 # if an image is not yet created do nothing
 if [ -z "$image" ]; then
  echo "Keine Image-Datei vorhanden."
  return
 fi
 echo -e "Sichere Aktivierungsdaten ... "
 # archive name contains mac address and image name
 local archive="/cache/$mac.$image.winact.tar.gz"
 local tmparchive="/cache/tokens.tar.gz"
 # generate tar command
 local tarcmd="tar czf $tmparchive"
 [ -n "$win_tokens" ] && tarcmd="$tarcmd $win_tokens"
 [ -n "$office_tokens" ] && tarcmd="$tarcmd $office_tokens"
 # create temporary archive
 if ! $tarcmd &> /dev/null; then
  echo "Sorry. Fehler beim Erstellen von $tmparchive."
  return 1
 else
  echo "OK."
 fi
 # merge old and new if archive already exists
 local RC=0
 if [ -s "$archive" ]; then
  echo -e "Aktualisiere $archive ... "
  local tmpdir="/cache/tmp"
  local curdir="$(pwd)"
  [ -e "$tmpdir" ] && rm -rf "$tmpdir"
  mkdir -p "$tmpdir"
  tar xf "$archive" -C "$tmpdir" || RC="1"
  tar xf "$tmparchive" -C "$tmpdir" || RC="1"
  rm -f "$archive"
  rm -f "$tmparchive"
  cd "$tmpdir"
  tar czf "$archive" * &> /dev/null || RC="1"
  cd "$curdir"
  rm -rf "$tmpdir"
 else # use temporary archive if it does not exist already
  echo -e "Erstelle $archive ... "
  rm -f "$archive"
  mv "$tmparchive" "$archive" || RC="1"
 fi
 # if error occured
 if [ "$RC" = "1" -o ! -s "$archive" ]; then
  echo "Fehlgeschlagen. Sorry."
  return 1
 else
  echo "OK."
 fi
 # do not in offline mode
 [ -e /tmp/linbo-network.done ] && return
 # trigger upload
 echo "Veranlasse Upload der Windows-Aktivierungstokens."
 rsync "$server::linbo/winact/$(basename $archive).upload" /cache &> /dev/null || true
}

# save windows activation tokens
do_housekeeping(){
 local device=""
 local cachedev="$(printcache)"
 [ -b "$cachedev" ] || return 1
 if ! mount "$cachedev" /cache; then
  echo "Housekeeping: Kann Cachepartition $cachedev nicht mounten."
  return 1
 fi
 grep -i ^root /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }' | sort -u | while read device; do
  [ -b "$device" ] || continue
  if mount "$device" /mnt 2> /dev/null; then
   # save windows activation files
   ls /mnt/linuxmuster-win/*activation_status &> /dev/null && save_winact
   umount /mnt
  fi
 done
 mount | grep -v grep | grep -q /cache && umount /cache
}

# update linbo and install it locally
do_linbo_update(){
 local server="$1"
 local cachedev="$(printcache)"
 local customcfg="/cache/boot/grub/custom.cfg"
 local rebootflag="/tmp/.linbo.reboot"
 # save current custom.cfg
 linbo_cmd update "$server" "$cachedev" 2>&1 | tee /cache/update.log
 # test if linbofs or custom.cfg were updated on local boot
 if [ -n "$localboot" -a -e "$rebootflag" ]; then
  echo "Lokale LINBO/GRUB-Konfiguration wurde aktualisiert. Starte neu ..."
  cd /
  umount -a &> /dev/null
  /sbin/reboot -f
 else
  [ -e /cache/update.log ] && cat /cache/update.log >> /tmp/linbo.log
 fi
}

# disable auto functions from cmdline
disable_auto(){
 sed -e 's|^[Aa][Uu][Tt][Oo][Pp][Aa][Rr][Tt][Ii][Tt][Ii][Oo][Nn].*|AutoPartition = no|g
         s|^[Aa][Uu][Tt][Oo][Ff][Oo][Rr][Mm][Aa][Tt].*|AutoFormat = no|g
         s|^[Aa][Uu][Tt][Oo][Ii][Nn][Ii][Tt][Cc][Aa][Cc][Hh][Ee].*|AutoInitCache = no|g' -i /start.conf
}

# handle autostart from cmdline
set_autostart() {
 # return if autostart shall be suppressed generally
 if [ "$autostart" = "0" ]; then
  echo "Deaktiviere autostart generell."
  # set all autostart parameters to no
  sed -e 's|^[Aa][Uu][Tt][Oo][Ss][Tt][Aa][Rr][Tt].*|Autostart = no|g' -i /start.conf
  return
 fi
 # count [OS] entries
 local counts="$(grep -ci ^"\[OS\]" /start.conf)"
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
   echo "Aktiviere autostart fuer OS Nr. $c."
   echo "Autostart = yes" >> /start.conf.new
   found=0
  fi
 done </start.conf
 mv /start.conf.new /start.conf
}

# disable start, sync and new buttons
disable_buttons(){
 [ -s /start.conf ] || return
 echo "Deaktiviere Buttons."
 sed -e 's|^[Ss][Tt][Aa][Rr][Tt][Ee][Nn][Aa][Bb][Ll][Ee][Dd].*|StartEnabled = no|g
         s|^[Ss][Yy][Nn][Cc][Ee][Nn][Aa][Bb][Ll][Ee][Dd].*|SyncEnabled = no|g
         s|^[Nn][Ee][Ww][Ee][Nn][Aa][Bb][Ll][Ee][Dd].*|NewEnabled = no|g
         s|^[Hh][Ii][Dd][Dd][Ee][Nn].*|Hidden = yes|g' -i /start.conf
}

network(){
 echo
 echo "Starte Netzwerkkonfiguration ..."
 if [ -n "$localmode" ]; then
  echo "Localmode konfiguriert, ueberspringe Netzwerkkonfiguration."
  copyfromcache "start.conf icons"
  do_housekeeping
  touch /tmp/linbo-network.done
  return 0
 fi
 rm -f /tmp/linbo-network.done
 if [ -n "$ipaddr" ]; then
  echo "Benutze statische IP-Adresse $ipaddr."
  [ -n "$netmask" ] && nm="netmask $netmask" || nm=""
  ifconfig ${netdevice:-eth0} $ipaddr $nm &> /dev/null
 else
  # iterate over ethernet interfaces
  echo "Frage IP-Adresse per DHCP an ..."
  # dhcp retries
  [ -n "$dhcpretry" ] && dhcpretry="-t $dhcpretry"
  local RC="0"
  for dev in `grep ':' /proc/net/dev | awk -F\: '{ print $1 }' | awk '{ print $1}' | grep -v ^lo`; do
   echo "Interface $dev ... "
   ifconfig "$dev" up &> /dev/null
   # activate wol
   ethtool -s "$dev" wol g &> /dev/null
   # check if using vlan
   if [ -n "$vlanid" ]; then
    echo "Benutze VLAN-ID $vlanid."
    vconfig add "$dev" "$vlanid" &> /dev/null
    dhcpdev="$dev.$vlanid"
    ip link set dev "$dhcpdev" up
   else
    dhcpdev="$dev"
   fi
   udhcpc -n -i "$dhcpdev" $dhcpretry &> /dev/null ; RC="$?"
   if [ "$RC" = "0" ]; then
    # set mtu
    [ -n "$mtu" ] && ifconfig "$dev" mtu $mtu &> /dev/null
    break
   fi
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
  echo "Lade Konfigurationsdateien von $server ..."
  for i in "start.conf-$ipaddr" "start.conf"; do
   rsync -L "$server::linbo/$i" "start.conf" &> /dev/null && break
  done
  # set flag for working network connection
  if [ -s start.conf ]; then
   echo "Netwerkverbindung zu $server erfolgreich hergestellt."
   echo > /tmp/network.ok
  fi
  # linbo update
  do_linbo_update "$server"
  # also look for other needed files
  for i in "torrent-client.conf" "multicast.list"; do
   rsync -L "$server::linbo/$i" "/$i" &> /dev/null
  done
  # get optional onboot linbo-remote commands
  rsync -L "$server::linbo/linbocmd/$ipaddr.cmd" "/linbocmd" &> /dev/null
  if [ -s "/linbocmd" ]; then
   for i in noauto nobuttons; do
    grep -q "$i" /linbocmd && eval "$i"=yes
    sed -e "s|$i||" -i /linbocmd
   done
   # strip leading and trailing spaces and escapes
   linbocmd="$(awk '{$1=$1}1' /linbocmd)"
   sed -e 's|\\||g' -i /linbocmd
  fi
  # and (optional) the GUI icons
  for i in linbo_wallpaper.png $(grep -i ^iconname /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }'); do
   rsync -L "$server::linbo/icons/$i" /icons &> /dev/null
  done
  # save downloaded stuff to cache
  copytocache
 fi
 # copy start.conf optionally given on cmdline
 copyextra && local extra=yes
 # if start.conf could not be downloaded
 if [ ! -s start.conf ]; then
  # No new version / no network available, look for cached copies of start.conf and icons folder.
  copyfromcache "start.conf icons"
  # Still nothing new, revert to old version.
  [ ! -s start.conf ] && mv -f start.conf.dist start.conf
 fi
 # modify cache in start.conf if cache was given and no extra start.conf was defined
 [ -z "$extra" -a -b "$cache" ] && modify_cache /start.conf
 # disable auto functions if noauto is given
 if [ -n "$noauto" ]; then
  autostart=0
  disable_auto
 fi
 # set autostart if given on cmdline
 isinteger "$autostart" && set_autostart
 # disable buttons if nobuttons is given on cmdline
 [ -n "$nobuttons" ] && disable_buttons
 # sets flag if no default route
 route -n | grep -q ^0\.0\.0\.0 || echo > /tmp/.offline
 # start ssh server
 echo "Starte SSH-Server."
 /sbin/dropbear -s -g -E -p 2222 &> /dev/null
 # remove reboot flag, save windows activation
 do_housekeeping
 # done
 echo > /tmp/linbo-network.done
 echo "Fertig."
 rm -f /outfifo
}

# HW Detection
hwsetup(){
 rm -f /tmp/linbo-cache.done
 echo "## Hardware-Setup - Anfang ##" >> /tmp/linbo.log

 #
 # Udev starten
 echo > /sys/kernel/uevent_helper
 mkdir -p /run/udev
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
 echo "## Hardware-Setup - Ende ##" >> /tmp/linbo.log

 sleep 2
 echo > /tmp/linbo-cache.done
}

# Main
#clear
echo
echo 'Willkommen zu'
echo ' _      _____ _   _ ____   ____'
echo '| |    |_   _| \ | |  _ \ / __ \'
echo '| |      | | |  \| | |_) | |  | |'
echo '| |      | | | . ` |  _ <| |  | |'
echo '| |____ _| |_| |\  | |_) | |__| |'
echo '|______|_____|_| \_|____/ \____/'
echo

# initial setup
read_cmdline
echo
echo "Konfiguriere Hardware ..."
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
 if [ -n "$linbocmd" ]; then
  OIFS="$IFS"
  IFS=","
  for cmd in $linbocmd; do
   /usr/bin/linbo_wrapper "$cmd"
  done
  IFS="$OIFS"
 fi
 exit 0
fi

# splash mode

# convert wallpaper to splash image
pngtopnm /icons/linbo_wallpaper.png > /etc/splash.pnm

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

# read downloaded onboot linbocmds
[ -e /linbocmd ] && linbocmd="$(cat /linbocmd)"

# console output for linbo commands
if [ -n "$linbocmd" ]; then

 # start progress bar
 ( count=0; while true; do sleep 1; echo $count > /fbfifo; count=$(($count + 10)); [ $count -gt $MAXCOUNT ] && count=0; done ) &
 pb_pid="$!"

 # iterate over on commandline given linbo commands
 OIFS="$IFS"
 IFS=","
 n=1
 for cmd in $linbocmd; do

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
 IFS="$OIFS"
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
