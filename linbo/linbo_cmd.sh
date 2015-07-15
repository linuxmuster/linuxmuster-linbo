#!/bin/sh
# linbo_cmd - Backend worker script for LINBO
# (C) Klaus Knopper 2007-2010
#
# paedML/openML modifications by Thomas Schmitt
#
# ssd/4k/8k support - jonny@bzt.de 30.09.2012 alpha!
# ssd/4k/8k support - jonny@bzt.de 06.11.2012 anpassung fuer 2.0.12
#
# thomas@linuxmuster.net
# 13.07.2015
# GPL v3
#

CLOOP_BLOCKSIZE="131072"
RSYNC_PERMISSIONS="--chmod=ug=rw,o=r"

trap bailout 1 2 3 10 12 13 15

umask 002

PID="$$"

TMP="/tmp/linbo_cmd.$$.tmp"
rm -f "$TMP"

# Nur zum Debuggen
# echo "»linbo_cmd«" "»$@«"
ps w | grep linbo_cmd | grep -v grep >"$TMP"
if [ $(cat "$TMP" | wc -l) -gt 1 ]; then
# echo "Possible Bug detected: linbo_cmd already running." >&2
 echo "Possible Bug detected: linbo_cmd already running." >> /tmp/linbo.log
 #cat "$TMP" >&2
 cat "$TMP" >> /tmp/linbo.log
fi
rm -f "$TMP"
# EOF Debugging

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

printargs(){
 local arg
 local count=1
 for arg in "$@"; do
  echo -n "$((count++)):»$arg« "
 done
 echo ""
}

# test if variable is an integer
isinteger() {
 [ $# -eq 1 ] || return 1
 case $1 in
 *[!0-9]*|"") return 1;;
           *) return 0;;
 esac
}

# Is /cache writable?
# Displayed mount permissions may not be correct, do a write-test.
cache_writable(){
local testfile="/cache/.write_test"
 [ -f "$testfile" ] && rm -f "$testfile" 2>/dev/null
 echo > "$testfile" 2>/dev/null
 local RC="$?"
 [ -f "$testfile" ] && rm -f "$testfile" 2>/dev/null
 return "$RC"
}

# Check for "nonetwork" boot option or availability of linbo server
localmode(){
 case "$(cat /proc/cmdline)" in *\ nonetwork*|*\ localmode*) return 0;; esac
 [ -e /tmp/network.ok ] && return 1
 return 0
}

# tschmitt: send logfile to linbo user on the server or store it local in cache
sendlog(){
 local RC="1"
 local logfile
 if [ -s /etc/sendlog.conf ]; then
  . /etc/sendlog.conf
 elif [ -s /tmp/dhcp.log ]; then
  local domain="$(grep -m1 ^domain= /tmp/dhcp.log | awk -F\' '{ print $2 }')"
  local logname="$(grep -m1 ^hostname= /tmp/dhcp.log | awk -F\' '{ print $2 }')"
  local serverip="$(grep -m1 ^siaddr= /tmp/dhcp.log | awk -F\' '{ print $2 }')"
  echo "local domain=$domain" > /etc/sendlog.conf
  echo "local logname=$logname" >> /etc/sendlog.conf
  echo "local serverip=$serverip" >> /etc/sendlog.conf
 fi
 for logfile in patch.log image.log linbo.log; do
  if [ -s "/tmp/$logfile" ]; then
   if localmode; then
    if cache_writable; then
     echo "Speichere Logdatei $logfile im Cache."
     cp "/tmp/$logfile" /cache
    fi
   else
    echo "Sende Logdatei an $serverip."
    local body="$(cat /tmp/$logfile)"
    ssmtp -oi linbo@$domain << EOF
To: linbo@$domain
Subject: LOG $logname $logfile

$body
EOF
    RC="$?"
   fi
   if [ "$RC" = "0" ]; then
    rm /tmp/$logfile
    echo "Logdatei $logfile erfolgreich an $serverip versandt."
   else
    if cache_writable; then
     echo "Speichere Logdatei $logfile im Cache."
     cp "/tmp/$logfile" /cache
    fi
   fi
  fi
 done
}

# File patterns for exclusion when creating/restoring rsync-archives
# These patterns should match through the entire filesystem tree.
# When cleaning up before compression, however, they will be prefixed
# by "/", in order to get applied only for the root file system.
#
# Should match common Windows/Linux garbage
RSYNC_EXCLUDE='[Pp][Aa][Gg][Ee][Ff][Ii][Ll][Ee].[Ss][Yy][Ss]
[Hh][Ii][Bb][Ee][Rr][Ff][Ii][Ll].[Ss][Yy][Ss]
[Hh][Ii][Bb][Ee][Rr][Nn][Aa][Tt][Ee].[Ss][Yy][Ss]
[Ww][Ii][Nn]386.[Ss][Ww][Pp]
Papierkorb/*
[Rr][Ee][Cc][Yy][Cc][Ll][Ee][DdRr]/*
\$[Rr][Ee][Cc][Yy][Cc][Ll][Ee].[Bb][Ii][Nn]/*
[Ll][Ii][Nn][Bb][Oo].[Ll][Ss][Tt]
swapfile
tmp/*
var/log/ConsoleKit/history
var/tmp/*'

bailout(){
 echo "DEBUG: bailout() called, linbo_cmd=$PID, my_pid=$$" >&2
 echo ""
 # Kill all processes that have our PID as PPID.
 local processes=""
 local names=""
 local pid=""
 local cmd=""
 local stat=""
 local relax=""
 local statfile=""
 for statfile in /proc/[1-9]*/stat; do
  while read pid cmd stat ppid relax; do
   if [ "$ppid" = "$PID" ]; then
    processes="$processes $pid"
    names="$names $cmd"
   fi
  done <"$statfile"
 done
 if [ -n "$processes" ]; then
   echo "Beende Prozesse: $processes $names" >&2
   kill $processes
   sleep 1
   echo ""
 fi
 cd /
 sync; sync; sleep 1
 umount /mnt >/dev/null 2>&1 || umount -l /mnt >/dev/null 2>&1
 sendlog
 umount /cache >/dev/null 2>&1 || umount -l /cache >/dev/null 2>&1
 umount /cloop >/dev/null 2>&1 || umount -l /cloop >/dev/null 2>&1
 rmmod cloop >/dev/null 2>&1
 rm -f "$TMP" /tmp/rsync.exclude
 echo "Abgebrochen." >&2
 echo "" >&2
 exit $?
}

interruptible(){
 local RC=0
 # "$@" >"$TMP" 2>&1 &
 "$@" &
 local newpid="$!"
 wait
 RC="$?"
 case "$RC" in
  0) true ;;
  2) kill "$newpid"; cd /; bailout 0 ;;
#  *) [ -s "$TMP" ] && cat "$TMP" >&2 ;;
 esac
 return "$RC"
}

help(){
echo "
 Invalid LINBO command: »$@«

 Syntax: linbo_cmd command option1 option2 ...

 Examples:
 start bootdev rootdev kernel initrd append
               - boot OS
 syncr server  cachedev baseimage image bootdev rootdev kernel initrd
               - sync cache from server AND partitions from cache
 syncl cachedev baseimage image bootdev rootdev kernel initrd
               - sync partitions from cache

 Image types: 
 .cloop - full block device (partition) image, cloop-compressed
 .rsync - differential rsync batch, cloop-compressed
 " 1>&2
}

cmd="$1"
[ -n "$cmd" ] && shift # Command args are now $@

# fstype partition
fstype(){
 local phead="$(dd if="$1" bs=128k count=2 2>/dev/null)"
 local RC="$?"
 [ "$RC" = "0" ] || return "$RC"
 case "$phead" in
  *NTFS*) echo "ntfs" ;;
  # tschmitt: we also need to know fat
  *[Mm][Kk][Dd][Oo][Ss][Fs][Ss]*|*[Ff][Aa][Tt]*) echo "vfat" ;;
  *[Rr][Ee][Ii][Ss][Ee][Rr]*) echo "reiserfs" ;;
  *) echo "auto" ;;
 esac
 return 0
}

# tschmitt
# get DownloadType from start.conf
downloadtype(){
 local RET=""
 if [ -s /start.conf ]; then
  RET="$(grep -i ^downloadtype /start.conf | tail -1 | awk -F= '{ print $2 }' | awk '{ print $1 }' | tr A-Z a-z)"
  # get old option for compatibility issue
  if [ -z "$RET" ]; then
   RET="$(grep -i ^usemulticast /start.conf | tail -1 | awk -F= '{ print $2 }' | awk '{ print $1 }' | tr A-Z a-z)"
   [ "$RET" = "yes" ] && RET="multicast"
  fi
 fi
 echo "$RET"
}

# tschmitt
# fetch hostgroup from start.conf
hostgroup(){
 local hostgroup=""
 [ -s /start.conf ] || return 1
 hostgroup=`grep -i ^group /start.conf | tail -1 | awk -F= '{ print $2 }' | awk '{ print $1 }'`
 echo "$hostgroup"
}

# fschuett
# fetch SystemType from start.conf
systemtype(){
 local systemtype="bios"
 [ -s /start.conf ] || return 1
 systemtype=`grep -i ^SystemType /start.conf | tail -1 | awk -F= '{ print $2 }' | awk '{ print $1 }'`
 echo "$systemtype"
}

kerneltype(){
 local kerneltype="linbo"
 local systemtype=$(systemtype)
 case $systemtype in
   bios64|efi64)
       kerneltype="linbo64"
   ;;
   *)
   ;;
 esac
 echo "$kerneltype"
}

kernelfstype(){
 local kernelfstype="linbofs.lz"
 local systemtype=$(systemtype)
 case $systemtype in
   bios64|efi64)
       kernelfstype="linbofs64.lz"
   ;;
   *)
   ;;
 esac
 echo "$kernelfstype"
}

# fschuett
# extract block device name for sd?,/dev/sd?,*blk?p?,/dev/*blk?p?
# get_disk_from_partition partition
get_disk_from_partition(){
  local p="$1"
  local disk=
  expr "$p" : ".*p[[:digit:]][[:digit:]]*" >/dev/null && disk=${p%%p[0-9]*}
  expr "$p" : ".*sd[[:alpha:]][[:digit:]][[:digit:]]*" >/dev/null && disk=${p%%[0-9]*}
  if [[ -n "$disk" ]]; then
    echo "$disk"
    return 0
  else
    echo "$1"
    return 1
  fi
}

# fschuett
# extract disk device names from start.conf partition definitions
# get_disks
get_disks(){
  local parts="$(grep -i ^dev /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }' )"
  local disks=
  for p in $parts; do
    disks="$disks $(get_disk_from_partition "$p")"
  done;
  disks="$(echo $disks|tr " " "\n"|sort -u)"
  echo "$disks"
  return 0
}


# tschmitt
# fetch fstype from start.conf
# fstype_startconf dev
fstype_startconf(){
 local dev="$1"
 local type=""
 local section=""
 local param=""
 local tdev=""
 local pfound=0
 local dfound=0
 local line=""
 if [ ! -e /start.conf ]; then
   echo "Fatal! start.conf nicht gefunden!"
   return 1
 fi
 while read line; do
  section=`echo $line | awk '{ print $1 }' | tr A-Z a-z`
  [ "$section" = "[partition]" ] && pfound=1
  if [ "$pfound" = 1 ]; then
    param=`echo $line | awk '{ print $1 }' | tr A-Z a-z`
    if [ "$param" = "dev" ]; then
     tdev=`echo $line | awk -F= '{ print $2 }' | awk '{ print $1 }'`
     if [ "$tdev" = "$dev" ]; then
      dfound=1
     else
      pfound=0; dfound=0; type=""
     fi
    fi
    if [ "$param" = "fstype" ]; then
     type=`echo $line | awk -F= '{ print $2 }' | awk '{ print $1 }' | tr A-Z a-z`
    fi
    if [ "$dfound" = 1 -a -n "$type" ]; then
     echo "$type"
     return 0
    fi
  fi
 done </start.conf
 return 1
}

# mountpart partition destdir [options]
mountpart(){
 local RC=0
 local type=""
 local i=0
 local wmsg=0
 # "noatime" is required for later remount, otherwise kernel will default to "relatime",
 # which busybox mount does not know
 local OPTS="noatime"
 if [ "$3" = "-r" ]; then OPTS="$OPTS,ro"; else OPTS="$OPTS,rw"; fi
 # fix vanished cloop symlink
 if [ "$1" = "/dev/cloop" ]; then
  # wait for cloop0 to appear
  for i in 1 2 3 4 5; do
   if [ -b /dev/cloop0 ]; then
    rm -f /dev/cloop
    ln -sf /dev/cloop0 /dev/cloop
    break
   else
    [ "$i" = "5" ] && break
    echo "Cloop-Device ist noch nicht verfuegbar, versuche erneut..."
    wmsg=1
    sleep 2
   fi
  done
  if [ ! -b /dev/cloop0 ]; then
   echo "Cloop-Device ist nicht bereit! Breche ab!"
   return 1
  else
   [ "$wmsg" = "1" ] && echo "...Ok! :-)"
  fi
 fi
 # wait for partition
 for i in 1 2 3 4 5; do
  type="$(fstype $1)"
  RC="$?"
  [ "$RC" = "0" ] && break
  [ "$i" = "5" ] && break
  echo "Partition $1 ist noch nicht verfuegbar, versuche erneut..."
  sleep 2
 done
 [ "$RC" = "0" ] || { echo "Partition $1 ist nicht verfuegbar, wurde die Platte schon partitioniert?" 1>&2; return "$RC"; }
 case "$type" in
  *ntfs*)
   OPTS="$OPTS,recover,remove_hiberfile,user_xattr,inherit,acl"
   ntfs-3g "$1" "$2" -o "$OPTS" 2>/dev/null; RC="$?"
   ;;
  *fat*)
   mount -o "$OPTS" "$1" "$2" ; RC="$?"
   ;;
  *)
   OPTS="$OPTS,acl,user_xattr"
   mount -o "$OPTS" "$1" "$2" ; RC="$?"
   ;;
 esac
 [ "$RC" = "0" ]
 return "$RC"
}

# Return true if cache is NFS- or SAMBA-Share
remote_cache(){
 case "$1" in *:*|*//*|*\\\\*) return 0 ;; esac
 return 1
}

# format dev fs
format(){
 echo -n "format " ;  printargs "$@"
# local dev="${1%%[0-9]*}"
# local part="${1#$dev}"
 local cmd
 local RC
 case "$2" in
  swap) cmd="mkswap $1" ;;
  reiserfs) cmd="mkreiserfs -f -f  $1" ;;
  ext2|ext3|ext4) cmd="mkfs.$2 $1" ;;
  [Nn][Tt][Ff][Ss]*) cmd="mkfs.ntfs -Q $1" ;;
  *[Ff][Aa][Tt]*) cmd="mkdosfs -F 32 $1" ;;
  *) return 1 ;;
 esac
 echo "Formatiere $1 mit $2."
 $cmd ; RC="$?"
 if [ "$RC" != "0" ]; then
  echo "Partition $1 ist noch nicht bereit. Versuche nochmal."
  sleep 2
  $cmd ; RC="$?"
 fi
 if [ "$RC" = "0" ]; then
  echo "$1 erfolgreich mit $2 formatiert."
 else
  echo "Formatieren von $1 mit $2 gescheitert!"
 fi
 return "$RC"
}

# mountcache partition [options]
mountcache(){
 local RC=1
 [ -n "$1" ] || return 1
 export CACHE_PARTITION="$1"
 # Avoid duplicate mounts by just preparing read/write mode
 if grep -q "^$1 " /proc/mounts; then
  local RW
  grep -q "^$1 .*rw.*" /proc/mounts && RW="true" || RW=""
  case "$2" in
   -r|-o\ *ro*) [ -n "$RW" ] && mount -o remount,ro /cache 2>> /tmp/linbo.log ; RC=0 ;; 
   *) [ -n "$RW" ] || mount -o remount,rw /cache 2>> /tmp/linbo.log ; RC="$?" ;; 
  esac
  return "$RC"
 fi
 case "$1" in
  *:*) # NFS
   local server="${1%%:*}"
   local dir="${1##*:}"
   echo "Mounte /cache per NFS von $1..."
   # -o nolock is EXTREMELY important here, otherwise mount.nfs will timeout waiting for
   # local portmap
   mount $2 -t nfs -o nolock,rsize=8192,wsize=8192,hard,intr "$1" /cache 2>> /tmp/linbo.log
   RC="$?"
   ;;
  \\\\*\\*|//*/*) # CIFS/SAMBA
   local server="${1%\\*}";  server="${server%/*}"; server="${server#\\\\}"; server="${server#//}"
   echo "Mounte /cache per SAMBA/CIFS von $1..."
   # unix extensions have to be disabled
   echo 0 > /proc/fs/cifs/LinuxExtensionsEnabled 2>/dev/null
   # mount.cifs (3) pays attention to $PASSWD
   # this does not work: $RSYNC_PASSWORD is not available and mount.cifs does not pay attention to $PASSWD
   #export PASSWD="$RSYNC_PASSWORD"
   #mount $2 -t cifs -o username=linbo,nolock "$1" /cache 2>/dev/null
   # temporary workaround for password
   [ -s /tmp/linbo.passwd ] && PASSWD="$(cat /tmp/linbo.passwd 2>/dev/null)"
   [ -z "$PASSWD" -a -s /tmp/rsyncd.secrets ] && PASSWD="$(grep ^linbo /tmp/rsyncd.secrets | awk -F\: '{ print $2 }' 2>/dev/null)"
   mount $2 -t cifs -o user=linbo,pass="$PASSWD",nolock "$1" /cache 2>> /tmp/linbo.log
   RC="$?"
   if [ "$RC" != "0" ]; then
    echo "Zugriff auf $1 als User \"linbo\" mit Authentifizierung klappt nicht."
    mount $2 -t cifs -o nolock,guest,sec=none "$1" /cache 2>> /tmp/linbo.log
    RC="$?"
    if [ "$RC" != "0" ]; then
     echo "Zugriff als \"Gast\" klappt auch nicht."
    fi
   fi
   ;;
  /dev/*) # local cache
   # Check if cache partition exists
   if grep -q "${1##*/}" /proc/partitions; then
#    if cat /proc/mounts | grep -q /cache; then
#     echo "Cache ist bereits gemountet."
#     RC=0
#    else
     echo "Mounte Cachepartition $1 ..."
     mountpart "$1" /cache $2 2>> /tmp/linbo.log ; RC="$?"
#    fi
    if [ "$RC" != "0" ]; then
     # Cache partition has not been formatted yet?
     local cachefs="$(fstype_startconf "$1")"
     if [ -n "$cachefs" ]; then
      echo "Formatiere Cache-Partition..."
      format "$1" "$cachefs" 2>> /tmp/linbo.log
     fi
     # Retry.
     mountpart "$1" /cache $2 2>> /tmp/linbo.log ; RC="$?"
    fi
   else
    echo "Cache-Partition existiert nicht."
   fi
   ;;
   *) # Yet unknown
   echo "Unbekannte Quelle für LINBO-Cache: $1" >&2
   ;;
  esac
 [ "$RC" = "0" ] || echo "Kann $1 nicht als /cache einbinden." >&2
 return "$RC"
}

killalltorrents(){
 local WAIT=5
 # check for running torrents and kill them if any
 if [ -n "`ps w | grep ctorrent | grep -v grep`" ]; then
  echo "Killing torrents ..."
  killall -9 ctorrent 2>/dev/null
  sleep "$WAIT"
  [ -n "`ps w | grep ctorrent | grep -v grep`" ] && sleep "$WAIT"
 fi
}

# Changed: All partitions start on cylinder boundaries.
# partition dev1 size1 id1 bootable1 filesystem dev2 ...
# When "$NOFORMAT" is set, format is skipped, otherwise all
# partitions with known fstypes are formatted.
partition(){
 killalltorrents
 echo -n "partition " ;  printargs "$@"
 # umount /cache if mounted
 if cat /proc/mounts | grep -q /cache; then
  cd /
  if ! umount /cache &>/dev/null; then
   umount -l /cache &>/dev/null
   sleep "$WAIT"
   if cat /proc/mounts | grep -q /cache; then
    echo "Kann /cache nicht unmounten." >&2
    return 1
   fi
  fi
 fi

 # grep all disks from start.conf
 local disks="$(get_disks)"
 # compute the last partition of each disk
 local i=""
 for i in $disks; do
  local lastpartitions="$lastpartitions $(grep -i ^dev /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }' | sort -r | grep $i | head -1)"
 done

 while [ "$#" -ge "5" ]; do
  # support multiple disks
  local disk="$(get_disk_from_partition "$1")"
  if echo "$disks" | grep -q "$disk"; then
   disks="$(echo "$disks" | sed -e "s|$disk||")"
   local table=""
   local formats=""
   local cylinders=""
   local disksize=""
   local dummy=""
   local relax=""
   local pcount=0
   local fstype=""
   local bootable=""
   read d cylinders relax <<.
$(sfdisk -g "$disk" 2>> /tmp/linbo.log)
.
   read disksize relax <<.
$(sfdisk -s "$disk" 2>> /tmp/linbo.log)
.
   [ -n "$cylinders" -a "$cylinders" -gt 0 -a -n "$disksize" -a "$disksize" -gt 0 ] >/dev/null 2>&1 || { echo "Festplatten-Geometrie von $disk lässt sich nicht lesen, cylinders=$cylinders, disksize=$disksize, Abbruch." >&2; return 1; }
  fi
  # compute partition table
  local dev="$1"
  [ -n "$dev" ] || continue
  local csize=""
  if [ "$2" -gt 0 ] 2>/dev/null; then
   # knopper begin
   ## Cylinders = kilobytes * totalcylinders / totalkilobytes
   #csize="$(($2 * $cylinders / $disksize))"
   #[ "$(($csize * $disksize / $cylinders))" -lt "$2" ] && let csize++
   # knopper end
   # jonny begin
   # sektoren = kilobytes * 2 
   csize="$(($2 * 2))"
   # jonny end
  fi
  if [ -n "$table" ]; then
   table="$table
"
  fi
  let pcount++
  # Is this a primary partition?
  local partno="$(expr "$dev" : ".*\([[:digit:]]\)")" # fix syntax highlighting: "
  if [ "$partno" -gt 4 ] >/dev/null 2>&1; then
   # Fill up unused partitions
   while [ "$pcount" < 5 ]; do
    table="$table;
"
    let pcount++
   done
  fi
  # handle bootable flag
  bootable="$4"
  [ "$bootable" = "bootable" ] || bootable=""
  # handle fstype
  fstype="$5"
  [ "$fstype" = "-" ] && fstype=""
  # Insert table entry.
  # knopper begin
  # table="$table,$csize,$3${bootable:+,*}"
  # knopper end
  # jonny begin
  if [ "$pcount" -eq 1 ] >/dev/null 2>&1; then  
   table="2048,$csize,$3${bootable:+,*}"
   ts0="$csize"
  fi
  if [ "$pcount" -eq 2 ] >/dev/null 2>&1; then  
   table="$table$(($ts0 + 2048)),$csize,$3${bootable:+,*}"
   ts1="$csize"
  fi
  if [ "$pcount" -eq 3 ] >/dev/null 2>&1; then  
   table="$table$(($ts0 + $ts1 + 2048)),$csize,$3${bootable:+,*}"
   ts2="$csize"
  fi
  if [ "$pcount" -eq 4 ] >/dev/null 2>&1; then  
   if [ "$3" -eq 5 ] >/dev/null 2>&1; then  
    ts2=$(($ts2 + 2047))
   fi
   table="$table$(($ts0 + $ts1 + $ts2 + 2048)),$csize,$3${bootable:+,*}"
   ts3="$csize"
  fi
  if [ "$pcount" -eq 5 ] >/dev/null 2>&1; then  
   table="$table,$(($csize - 1)),$3${bootable:+,*}"
  fi
  if [ "$pcount" -gt 5 ] >/dev/null 2>&1; then  
   table="$table,$csize,$3${bootable:+,*}"
  fi
  # jonny end
  [ -n "$fstype" ] && formats="$formats $dev,$fstype"
  shift 5
  # write partition table if last disk partition is reached
  if echo "$lastpartitions" | grep -q "$dev"; then
   # sfdisk -D -f "$disk" 2>&1 <<EOT
   # jonny 
   sfdisk -uS -f "$disk" 2>> /tmp/linbo.log <<EOT
$table
EOT
   RC="$?"
   if [ "$RC" != "0" ]; then
    echo "Partitionierung von $disk gescheitert!"
    return "$RC"
   fi
   if [ -z "$NOFORMAT" ]; then
    sleep 2
    local i=""
    for i in $formats; do
     format "${i%%,*}" "${i##*,}" 2>> /tmp/linbo.log
    done
   fi # format
  fi # lastpartitions
 done
}

# mkgrub - writes grub stuff for local boot
mkgrub(){
 local grubdir="/cache/boot/grub"
 [ -e "$grubdir" ] || mkdir -p "$grubdir"
 # create a standard menu.lst for local boot which contains current linbo kernel params
 if [ ! -e /cache/.custom.menu.lst -a ! -e /tmp/.menulst.done -a -e /menu.lst ]; then
  echo "Erstelle menu.lst fuer lokalen Boot."
  local append=""
  local vga="vga=785"
  local kernel="$(kerneltype)"
  local i
  for i in $(cat /proc/cmdline); do
   case "$i" in
    BOOT_IMAGE=*|server=*|cache=*) true ;;
    *) append="$append $i" ;;
   esac
  done
  sed -e "s|^kernel /$kernel .*|kernel /$kernel $append|" /menu.lst > /cache/boot/grub/menu.lst
  touch /tmp/.menulst.done
 fi
 # return if grub-install is already done by earlier invokation
 [ -e /tmp/.mkgrub.done ] && return 0
 # grep all disks from start.conf
 local disks="$(grep -i ^dev /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }' | sed -e 's|[0-9]*||g' | sort -u)"
 if [ -z "$disks" ]; then
  echo "Keine Festplatten zur Grub-Installation gefunden!"
  return 1
 fi
 local d
 local n=0
 # create device.map which contains all disks
 local devicemap="/cache/boot/grub/device.map"
 rm -f "$devicemap"
 touch "$devicemap"
 for d in $disks; do
  [ -b "$d" ] || continue
  echo "(hd${n}) $d" >> "$devicemap"
  n=$(( n + 1 ))
 done
 # finally write grub to the mbr of all disks
 if [ -s "$devicemap" ]; then
  for d in `awk '{ print $2 }' "$devicemap"`; do
   echo "Installiere Grub in MBR auf $d."
   grub-install --root-directory=/cache "$d" >> /tmp/linbo.log
  done
  touch /tmp/.mkgrub.done
 fi
}

# tschmitt: mkgrldr bootpart bootfile
# Creates menu.lst on given windows partition
# /cache and /mnt is already mounted when this is called.
mkgrldr(){
 local menu="/mnt/menu.lst"
 local grubdisk="hd0"
 local bootfile="$2"
 local driveid="0x80"
 case "$1" in
  *[hsv]da) grubdisk=hd0; driveid="0x80" ;;
  *[hsv]db) grubdisk=hd1; driveid="0x81" ;;
  *[hsv]dc) grubdisk=hd2; driveid="0x82" ;;
  *[hsv]dd) grubdisk=hd3; driveid="0x83" ;;
 esac
 local grubpart="${1##*[hsv]d[a-z]}"
 grubpart="$((grubpart - 1))"
 bootlace.com --"$(fstype_startconf "$1")" --floppy="$driveid" "$1"
 echo -e "default 0\ntimeout 0\nhiddenmenu\n\ntitle Windows\nroot ($grubdisk,$grubpart)\nchainloader ($grubdisk,$grubpart)$bootfile" > $menu
 cp /usr/lib/grub/grldr /mnt
}

# download server file [important]
download(){
 local RC=1
 [ -n "$3" ] && echo "RSYNC Download $1 -> $2..."
 rm -f "$TMP"
 interruptible rsync -HaLz --partial "$1::linbo/$2" "$2" 2>"$TMP"; RC="$?"
 if [ "$RC" != "0" ]; then
  # Delete incomplete/defective/non-existent file (maybe we should check for returncde=23 first?)
  rm -f "$2" 2>/dev/null
  if [ -n "$3" ]; then
   # Verbose error message if file was important
   cat "$TMP" >&2
   echo "Datei $2 konnte nicht heruntergeladen werden." >&2
  fi
 fi
 rm -f "$TMP"
 return "$RC"
}

# request macct file to invoke samba password hash ldap upload stuff on the server
invoke_macct(){
 local serverip="$(grep -m1 ^linbo_server= /tmp/dhcp.log | awk -F\' '{ print $2 }')"
 [ -z "$serverip" ] && return
 [ -s /mnt/.linbo ] || return
 local image="$(cat /mnt/.linbo)"
 local macctfile
 if [ -e "/cache/${image}.rsync" ]; then
  macctfile="${image}.rsync.macct"
 elif [ -e "/cache/${image}.cloop" ]; then
  macctfile="${image}.cloop.macct"
 else
  return
 fi
 download "$serverip" "$macctfile" && echo "Maschinenpasswort auf $serverip wurde gesetzt."
 rm -f "/cache/$macctfile"
}

# start boot root kernel initrd append cache
start(){
 echo -n "start " ;  printargs "$@"
 local WINDOWS=""
 local LOADED=""
 local KERNEL="/mnt/$3"
 local INITRD=""
 local APPEND="$5"
 local i
 local cpunum=1
 local disk="${1%%[1-9]*}"
 if mountpart "$1" /mnt -w 2>> /tmp/linbo.log; then
  [ -n "$4" -a -r /mnt/"$4" ] && INITRD="--initrd=/mnt/$4"
  # tschmitt: repairing grub mbr on every start
  #if mountcache "$6" && cache_writable ; then
   #mkgrub "$disk"
  #fi
  (mountcache "$6" && cache_writable) && mkgrub
  case "$3" in
   *[Gg][Rr][Uu][Bb].[Ee][Xx][Ee]*)
    # tschmitt: use builtin grub.exe in any case
    KERNEL="/usr/lib/$3"
    [ -e "$KERNEL" ] || KERNEL="/usr/lib/grub.exe"
    # provide an APPEND line if no one is given
    [ -z "$APPEND" ] && APPEND="--config-file=map(rd) (hd0,0); map --hook; chainloader (hd0,0)/ntldr; rootnoverify(hd0,0) --device-map=(hd0) $disk"
    ;;
   *[Rr][Ee][Bb][Oo][Oo][Tt]*)
     # tschmitt: if kernel is "reboot" assume that it is a real windows, which has to be rebootet
     WINDOWS="yes"
     LOADED="true"
     echo "Schreibe Reboot-Flag auf $1."
     dd if=/dev/zero of=/mnt/.linbo.reboot bs=2k count=1 2>> /tmp/linbo.log
     cp /mnt/.linbo.reboot /mnt/.grub.reboot
     ;;
   *)
    if [ -n "$2" ]; then
     APPEND="root=$2 $APPEND"
    fi
    ;;
  esac
  # provide a menu.lst for grldr on win2k/xp
  if [ -e /mnt/[Bb][Oo][Oo][Tt][Mm][Gg][Rr] ]; then
   mkgrldr "$1" "/bootmgr"
   APPEND="$(echo $APPEND | sed -e 's/ntldr/bootmgr/')"
  elif [ -e /mnt/[Nn][Tt][Ll][Dd][Rr] ]; then
   mkgrldr "$1" "/ntldr"
  elif [ -e /mnt/[Ii][Oo].[Ss][Yy][Ss] ]; then
   # tschmitt: patch autoexec.bat (win98),
   if ! grep ^'if exist C:\\linbo.reg' /mnt/AUTOEXEC.BAT; then
    echo "if exist C:\linbo.reg regedit C:\linbo.reg" >> /mnt/AUTOEXEC.BAT
    unix2dos /mnt/AUTOEXEC.BAT
   fi
   # provide a menu.lst for grldr on win98
   mkgrldr "$1" "/io.sys"
   # change bootloader for win98 systems
   APPEND="$(echo $APPEND | sed -e 's/ntldr/io.sys/' | sed -e 's/bootmgr/io.sys/')"
  fi
 else
  echo "Konnte Betriebssystem-Partition $1 nicht mounten." >&2
  umount /mnt 2>/dev/null
  mountcache "$6" -r
  return 1
 fi
 # cause machine password stuff on server
 invoke_macct
 # kill torrents if any
 killalltorrents
 # No more timer interrupts (deprecated)
 #[ -f /proc/sys/dev/rtc/max-user-freq ] && echo "1024" >/proc/sys/dev/rtc/max-user-freq 2>/dev/null
 #[ -f /proc/sys/dev/hpet/max-user-freq ] && echo "1024" >/proc/sys/dev/hpet/max-user-freq 2>/dev/null
 if [ -z "$WINDOWS" ]; then
  echo "kexec -l $INITRD --append=\"$APPEND\" $KERNEL" >> /tmp/linbo.log
  kexec -l $INITRD --append="$APPEND" $KERNEL 2>&1 >> /tmp/linbo.log && LOADED="true"
  #sleep 3
 fi
 umount /mnt 2>/dev/null
 sendlog
 # do not umount cache if root = cache
 if [ "$2" != "$6" ]; then
  umount /cache || umount -l /cache 2>/dev/null
 fi
 if [ -n "$LOADED" ]; then
  # Workaround for missing speedstep-capability of Windows (deprecated)
  #local i=""
  #for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  # if [ -f "$i" ]; then
  #  echo "Setze CPU #$((cpunum++)) auf maximale Leistung."
  #  echo "performance" > "$i"
  # fi
  #done
  #[ "$cpunum" -gt "1" ] && sleep 4
  # We basically do a quick shutdown here.
  killall5 -15
  [ -z "$WINDOWS" ] && sleep 2
  echo -n "c" >/dev/console
  if [ -z "$WINDOWS" ]; then
   exec kexec -e --reset-vga &> /dev/null
   # exec kexec -e
   sleep 10
  else
   #sleep 2
   reboot -f
   #sleep 10
  fi
 else
  echo "Betriebssystem konnte nicht geladen werden." >&2
  return 1
 fi
}

# return partition size in kilobytes
# arg: partition
get_partition_size(){
 # fix vanished cloop symlink
 if [ "$1" = "/dev/cloop" ]; then
  [ -e "/dev/cloop" ] || ln -sf /dev/cloop0 /dev/cloop
 fi
 sfdisk -s "$1" 2>> /tmp/linbo.log
 return $?
}

# echo file size in bytes
get_filesize(){
 ls -l "$1" 2>/dev/null | awk '{print $5}' 2>/dev/null
 return $?
}

# mkexclude
# Create /tmp/rsync.exclude
mkexclude(){
rm -f /tmp/rsync.exclude
cat > /tmp/rsync.exclude <<EOT
${RSYNC_EXCLUDE}
EOT
}

# prepare_fs directory inputdev
# Removes all files from ${RSYNC_EXCLUDE} and saves win7 boot configuration in
# the root directory of the os.
prepare_fs(){
 (
  # remove excluded files
  cd "$1" || return 1
  local disk="${2%%[1-9]*}"
  local i=""
  for i in ${RSYNC_EXCLUDE}; do # Expand patterns
   if [ -e "$i" ]; then
    echo "Entferne $i."
    rm -rf "$i"
   fi
  done
  # save win7 bcd & mbr
  local targetdir="$(ls -d [Bb][Oo][Oo][Tt] 2> /dev/null)"
  if [ -n "$targetdir" ]; then
   local bcd="$(ls $targetdir/[Bb][Cc][Dd] 2> /dev/null)"
   local group="$(hostgroup)"
   if [ -n "$bcd" -a -n "$group" ]; then
    echo "Sichere Windows-7-Bootsektor-Dateien."
    # BCD group specific
    cp -f "$bcd" "$bcd"."$group"
    # 4 bytes mbr group specific
    local mbr=$targetdir/win7mbr.$group
    dd if=$disk of=$mbr bs=1 count=4 skip=440 2>> /tmp/linbo.log
    # ntfs partition id
    local ntfsid=$targetdir/ntfs.id
    dd if=$2 of=$ntfsid bs=8 count=1 skip=9 2>> /tmp/linbo.log
   fi
  fi
 )
}

# mk_cloop type inputdev imagename baseimage [timestamp]
mk_cloop(){
 echo "## $(date) : Starte Erstellung von $3." | tee -a /tmp/image.log
 #echo -n "mk_cloop " ;  printargs "$@" | tee -a /tmp/image.log
 # kill torrent process for this image
 local pid="$(ps w | grep ctorrent | grep "$3.torrent" | grep -v grep | awk '{ print $1 }')"
 [ -n "$pid" ] && kill "$pid"
 # remove torrent files
 [ -e "/cache/$3.torrent" ] && rm "/cache/$3.torrent"
 [ -e "/cache/$3.complete" ] && rm "/cache/$3.complete"
 local RC=1
 local size="$(get_partition_size $2)"
 local imgsize=0
 case "$1" in
  partition) # full partition dump
   if mountpart "$2" /mnt -w 2>> /tmp/linbo.log; then
    echo "Bereite Partition $2 (Größe=${size}K) für Komprimierung vor..." | tee -a /tmp/image.log
    prepare_fs /mnt "$2" | tee -a /tmp/image.log
    echo "Leeren Platz auffüllen mit 0en..." | tee -a /tmp/image.log
    # Create nulled files of size 1GB, should work on any FS.
    local count=0
    while true; do
     # tschmitt: log errors to image.log
     #interruptible dd if=/dev/zero of="/mnt/zero$count.tmp" bs=1024k count=1000 2>/dev/null || break
     interruptible dd if=/dev/zero of="/mnt/zero$count.tmp" bs=1024k count=1000 2>>/tmp/image.log || break
     [ -s "/mnt/zero$count.tmp" ] || break
     let count++
     echo "$(du -ch /mnt/zero*.tmp | tail -1 | awk '{ print $1 }') genullt... " | tee -a /tmp/image.log
    done
    # Sync is asynchronous, unless started twice at least.
    sync ; sync ; sync
    rm -f /mnt/zero*.tmp
    # we don't need the file list anymore
    #echo "Dateiliste erzeugen..." | tee -a /tmp/image.log
    #( cd /mnt/ ; find . | sed 's,^\.,,' ) > "$3".list
    umount /mnt || umount -l /mnt
   fi
   echo "Starte Kompression von $2 -> $3 (ganze Partition, ${size}K)." | tee -a /tmp/image.log
   echo "create_compressed_fs -B $CLOOP_BLOCKSIZE -L 1 -t 2 -s ${size}K $2 $3" | tee -a /tmp/image.log
   interruptible create_compressed_fs -B "$CLOOP_BLOCKSIZE" -L 1 -t 2 -s "${size}K" "$2" "$3" 2>&1 ; export RC="$?"
   if [ "$RC" = "0" ]; then
    # create status file
    if mountpart "$2" /mnt -w 2>> /tmp/linbo.log; then
     echo "${3%.cloop}" > /mnt/.linbo
     umount /mnt || umount -l /mnt
    fi
    # create info file
    imgsize="$(get_filesize $3)"
    # Adjust uncompressed image size with one additional cloop block
    size="$(($CLOOP_BLOCKSIZE / 1024 + $size))"
    mk_info "$3" "$2" "$size" "$imgsize" >"$3".info
    echo "Fertig." | tee -a /tmp/image.log
    ls -l "$3"
   else
    echo "Die Erstellung von $3 ist fehlgeschlagen. :(" | tee -a /tmp/image.log
   fi
  ;;
  differential)
   if mountpart "$2" /mnt -w 2>> /tmp/linbo.log; then
    rmmod cloop >/dev/null 2>&1
#    echo "modprobe cloop file=/cache/$4" | tee -a /tmp/image.log
    if test -s /cache/"$4" && modprobe cloop file=/cache/"$4"; then
     mkdir -p /cloop
     if mountpart /dev/cloop /cloop -r 2>> /tmp/linbo.log; then
      echo "Starte Kompression von $2 -> $3 (differentiell)." | tee -a /tmp/image.log
      prepare_fs /mnt "$2" | tee -a /tmp/image.log
      mkexclude
      # determine rsync opts due to fstype
      local type="$(fstype "$2")"
      case $type in
       *ntfs*) ROPTS="-HazAX" ;;
       *vfat*) ROPTS="-rtz" ;;
       *) ROPTS="-az" ;;
      esac
      interruptible rsync "$ROPTS" --exclude="/.linbo" --exclude-from="/tmp/rsync.exclude" --delete --delete-excluded --log-file=/tmp/image.log --log-file-format="" --only-write-batch="$3" /mnt/ /cloop 2>&1 ; RC="$?"
      umount /cloop
      if [ "$RC" = "0" ]; then
        imgsize="$(get_filesize $3)"
        mk_info "$3" "$2" "" "$imgsize" >"$3".info
        echo "Fertig." | tee -a /tmp/image.log
        ls -l "$3"
      else
       echo "Die Erstellung von $3 ist fehlgeschlagen. :(" | tee -a /tmp/image.log
      fi
     else
      RC="$?"
      # DEBUG, REMOVEME
       dmesg | tail -5 >&2
     fi
    else
     echo "Image $4 kann nicht eingebunden werden," | tee -a /tmp/image.log
     echo "ist aber für die differentielle Sicherung notwendig." | tee -a /tmp/image.log
     RC="$?"
    fi
    rmmod cloop >/dev/null 2>&1
    umount /mnt || umount -l /mnt
   else
    RC="$?"
   fi
  ;; 
 esac
 # create torrent file
 if [ "$RC" = "0" ]; then
  echo "Erstelle torrent Dateien ..." | tee -a /tmp/image.log
  touch "$3".complete
  local serverip="$(grep -i ^server /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }')"
  ctorrent -t -u http://"$serverip":6969/announce -s "$3".torrent "$3" | tee -a /tmp/image.log
 fi
 echo "## $(date) : Beende Erstellung von $3." | tee -a /tmp/image.log
 return "$RC"
}

# check_status partition imagefile:
# returns true if mountable & contains a version of the archive.
check_status(){
 local RC=1
 local base="${2##*/}"
 base="${base%.[Cc][Ll][Oo]*}"
 base="${base%.[Rr][Ss][Yy]*}"
 mountpart "$1" /mnt -r 2>> /tmp/linbo.log || return $?
 [ -s /mnt/.linbo ] && case "$(cat /mnt/.linbo 2>/dev/null)" in *$base*) RC=0 ;; esac
 umount /mnt || umount -l /mnt
# [ "$RC" = "0" ] && echo "Enthält schon eine Version von $2."
 return "$RC"
}

# update_status partition imagefile:
# Add information about installed archives to partition
update_status(){
 local base="${2##*/}"
 base="${base%.[Cc][Ll][Oo]*}"
 base="${base%.[Rr][Ss][Yy]*}"
 mountpart "$1" /mnt -w 2>> /tmp/linbo.log || return $?
 case "$2" in *.[Cc][Ll][Oo]*) rm -f /mnt/.linbo ;; esac
 echo "$base" >> /mnt/.linbo
 sync; sync; sleep 1
 umount /mnt || umount -l /mnt
 return 0
}

# restore complete ntfs cloop image, which is assigned to /dev/cloop
# cp_cloop_ntfs targetdev
cp_cloop_ntfs(){
 local RC=1
 local targetdev="$1"
 echo "Restauriere Partition $targetdev mit ntfsclone..." | tee -a /tmp/image.log
 interruptible ntfsclone -f --overwrite "$targetdev" /dev/cloop 2>> /tmp/image.log ; RC="$?"
 if [ "$RC" != "0" ]; then
  echo 'FEHLER!' | tee -a /tmp/image.log
  return "$RC"
 fi
 # check if resizing is necessary
 echo "Pruefe ob Dateisystem vergroessert werden muss..." | tee -a /tmp/image.log
 # save ntfs size infos in temp file
 ntfsresize -f -i "$targetdev" 2>> /tmp/image.log > /tmp/ntfs.info
 # get volume size in mb
 local volsizemb="$(grep "Current volume size" /tmp/ntfs.info | awk -F\( '{ print $2 }' | awk '{ print $1}')"
 # test if volsizemb is an integer value
 if ! isinteger "$volsizemb"; then
  echo "Kann Dateisystemgroesse nicht bestimmen." | tee -a /tmp/image.log
  return 1
 fi  
 echo "Dateisystem: $volsizemb MB" | tee -a /tmp/image.log
 # get partition size in mb
 local devsizemb="$(grep "Current device size" /tmp/ntfs.info | awk -F\( '{ print $2 }' | awk '{ print $1}')"
 # test if devsizemb is an integer value
 if ! isinteger "$devsizemb"; then
  echo "Kann Partitionsgroesse nicht bestimmen." | tee -a /tmp/image.log
  return 1
 fi
 echo "Partition  : $devsizemb MB" | tee -a /tmp/image.log
 # test if partition is larger than filesystem and adjust filesystem size if necessary
 if [ $devsizemb -gt $volsizemb ]; then
  echo "Dateisystem wird auf $devsizemb MB vergroessert." | tee -a /tmp/image.log
  # get partition size in bytes
  local devsize="$(grep "Current device size" /tmp/ntfs.info | awk '{ print $4}')"
  if ! isinteger "$devsize"; then
   echo "Kann Partitionsgroesse nicht bestimmen." | tee -a /tmp/image.log
   return 1
  fi
  # increase the filesystem size
  ntfsresize -f -s "$devsize" "$targetdev" ; RC="$?"
  [ "$RC" = "0" ] || echo "Vergroesserung von $targetdev ist fehlgeschlagen." | tee -a /tmp/image.log
 else
  echo "Vergroesserung ist nicht notwendig." | tee -a /tmp/image.log
  RC=0
 fi # devsizemb gt volsizemb
 return "$RC"
} # cp_cloop_ntfs

# INITIAL copy
# cp_cloop imagefile targetdev
cp_cloop(){
 echo "## $(date) : Starte Komplettrestore von $1." | tee -a /tmp/image.log
 echo -n "cp_cloop " ;  printargs "$@" | tee -a /tmp/image.log
 local RC=1
 local imagefile="$1"
 local targetdev="$2"
 rmmod cloop >/dev/null 2>&1
 # repair cloop link if vanished
 [ -e /dev/cloop ] || ln -s /dev/cloop0 /dev/cloop
 if test -s "$imagefile" && modprobe cloop file=/cache/"$imagefile"; then
  # restore ntfs partitions with ntfsclone
  if [ "$(fstype $targetdev)" = "ntfs" ]; then
   cp_cloop_ntfs "$targetdev" ; RC="$?"
  else
   # old cp_cloop stuff
   local s1="$(get_partition_size /dev/cloop)"
   local s2="$(get_partition_size $targetdev)"
   local block="$(($CLOOP_BLOCKSIZE / 1024))"
   if [ "$(($s1 - $block))" -gt "$s2" ] 2>/dev/null; then
    echo "FEHLER: Cloop Image $imagefile (${s1}K) ist größer als Partition $targetdev (${s2}K)" >&2 | tee -a /tmp/image.log
    echo 'FEHLER: Das passt nicht!' >&2 | tee -a /tmp/image.log
    rmmod cloop >/dev/null 2>&1
    return 1
   fi
   # Userspace program MAY be faster than kernel module (no kernel lock necessary)
   # Forking an additional dd makes use of a second CPU and speeds up writing
   ( interruptible extract_compressed_fs /cache/"$imagefile" - | dd of="$targetdev" bs=1M ) 2>> /tmp/linbo.log | tee -a /tmp/image.log
   #interruptible extract_compressed_fs /cache/"$1" "$2" 2>&1 | tee -a /tmp/image.log
   # interruptible dd if=/dev/cloop of="$2" bs=1024k
   RC="$?"
  fi
 else
  # cloop file could not be mounted
  RC="$?"
  # DEBUG, REMOVEME
  dmesg | tail -5
  echo "Fehler: Archiv \"$imagefile\" nicht vorhanden bzw. defekt oder Zielpartition \"$targetdev\" zu klein bzw. fehlerhaft." >&2 | tee -a /tmp/image.log
 fi
 rmmod cloop >/dev/null 2>&1
 [ "$RC" = "0" ] && update_status "$targetdev" "$imagefile"
 echo "## $(date) : Beende Komplettrestore von $imagefile." | tee -a /tmp/image.log
 return "$RC"
}


# differential/Synced
# sync_cloop imagefile targetdev
sync_cloop(){
 echo "## $(date) : Starte Synchronisation von $1." | tee -a /tmp/image.log
 # echo -n "sync_cloop " ;  printargs "$@"
 local RC=1
 local ROPTS="-HaAX"
 #local TMP=/tmp/sync_tmp.log
 #local ROPTS="-a"
 [ "$(fstype "$2")" = "vfat" ] && ROPTS="-rt"
 if mountpart "$2" /mnt -w 2>> /tmp/linbo.log; then
  case "$1" in
   *.[Rr][Ss][Yy]*)
    # tschmitt: added logging parameter
    #interruptible rsync "$ROPTS" --fake-super --compress --partial --delete --log-file=/tmp/image.log --log-file-format="" --read-batch="$1" /mnt >"$TMP" 2>&1 ; RC="$?"
    echo "Synchronisation laeuft ... bitte warten ..."
    #interruptible rsync "$ROPTS" --compress --delete --log-file=/tmp/image.log --log-file-format="" --read-batch="$1" /mnt >"$TMP" 2>&1 ; RC="$?"
    interruptible rsync "$ROPTS" --compress --delete --log-file=/tmp/image.log --log-file-format="" --read-batch="$1" /mnt 2>&1 ; RC="$?"
    if [ "$RC" != "0" ]; then
     cat "$TMP" >&2 | tee -a /tmp/image.log
     echo "Fehler beim Synchronisieren des differentiellen Images \"$1\" nach $2, rsync-Fehlercode: $RC." >&2 | tee -a /tmp/image.log
     #sleep 5
    fi
    rm -f "$TMP"
   ;;
   *.[Cc][Ll][Oo]*)
    rmmod cloop >/dev/null 2>&1
    echo "modprobe cloop file=/cache/$1"  | tee -a /tmp/image.log
    if test -s "$1" && modprobe cloop file=/cache/"$1"; then
     mkdir -p /cloop
     if mountpart /dev/cloop /cloop -r 2>> /tmp/linbo.log; then
      # file list is obsolete
      #list="$1".list
      #FROMLIST=""
      #[ -r "$list" ] && FROMLIST="--files-from=$list"
      mkexclude
      # knopper: added --inplace
      #[ "$(fstype "$2")" = "vfat" ] && ROPTS="$ROPTS --inplace"
      # tschmitt: added logging parameter
      #interruptible rsync "$ROPTS" --fake-super --partial --exclude="/.linbo" --exclude-from="/tmp/rsync.exclude" --delete --delete-excluded --log-file=/tmp/image.log --log-file-format="" /cloop/ /mnt >"$TMP" 2>&1 ; RC="$?"
      echo "Synchronisation laeuft ... bitte warten ..."
      interruptible rsync "$ROPTS" --exclude="/.linbo" --exclude-from="/tmp/rsync.exclude" --delete --delete-excluded --log-file=/tmp/image.log --log-file-format="" /cloop/ /mnt 2>&1 ; RC="$?"
      umount /cloop
      if [ "$RC" != "0" ]; then
       cat "$TMP" >&2 | tee -a /tmp/image.log
       echo "Fehler beim Restaurieren des Images \"$1\" nach $2, rsync-Fehlercode: $RC." >&2 | tee -a /tmp/image.log
       #sleep 5
      fi
      rm -f "$TMP"
     else
      RC="$?"
      # DEBUG/REMOVEME
      dmesg | tail -5
      echo "Fehler: /cloop kann nicht vom Image \"$1\" gemountet werden." >&2 | tee -a /tmp/image.log
     fi
    else
     RC="$?"
     echo "Fehler: Image \"$1\" fehlt oder ist defekt." >&2 | tee -a /tmp/image.log
    fi
    rmmod cloop >/dev/null 2>&1
   ;;
  esac
  sync; sync; sleep 1
  umount /mnt || umount -l /mnt
 else
  RC="$?"
 fi
 [ "$RC" = "0" ] && update_status "$2" "$1"
 echo "## $(date) : Beende Synchronisation von $1." | tee -a /tmp/image.log
 return "$RC"
}

# restore imagefile targetdev [force]
restore(){
 #echo -n "restore " ;  printargs "$@"
 local RC=1
 local disk="${2%%[1-9]*}"
 local force="$3"
 local fstype="$(fstype_startconf "$2")"
 echo -n "Entpacke: $1 -> $2 "
 case "$1" in
  *.[Cc][Ll][Oo]*)
   if [ "$force" != "force" ]; then
    check_status "$2" "$1" || force="force"
   fi
   if [ "$force" = "force" ]; then
    echo "[Komplette Partition]..."
    format "$2" "$fstype" 2>> /tmp/linbo.log || return 1
   else
    echo "[Datei-Sync]..."
   fi
   if [ "$force" = "force" -a "$fstype" = "ntfs" ]; then
    cp_cloop "$1" "$2" ; RC="$?"
   else
    sync_cloop "$1" "$2" ; RC="$?"
   fi
   ;;
  *.[Rr][Ss][Yy]*)
   echo "[Datei-Sync]..."
   sync_cloop "$1" "$2" ; RC="$?"
   ;;
 esac
 if [ "$RC" = "0" ]; then
  echo "Fertig."
 else
  return "$RC"
 fi
 return "$RC"
}

# tschmitt
# patch fstab with root partition and root fstype: patch_fstab rootdev
patch_fstab(){
 echo -n "patch_fstab " ;  printargs "$@"
 local rootdev="$1"
 local line=""
 local found=""
 local fstype_mount=""
 local fstype_fstab=""
 local mntpnt=""
 local changed=""
 local rootdev_fstab=""
 local options=""
 local dump=""
 local pass=""
 [ -z "$rootdev" ] && return 1
 [ -e "$rootdev" ] || return 1
 [ -e /tmp/fstab ] && rm -f /tmp/fstab
 while read line; do
  if [ -n "$line" -a "${line:0:1}" != "#" ]; then
   mntpnt="$(echo "$line" | awk '{ print $2 }')"
   if [ "$mntpnt" = "/" -a -z "$found" ]; then
    found=yes
    rootdev_fstab="$(echo "$line" | awk '{ print $1 }')"
    [ -z "$rootdev_fstab" ] && return 1
    fstype_fstab="$(echo "$line" | awk '{ print $3 }')"
    [ -z "$fstype_fstab" ] && return 1
    options="$(echo "$line" | awk '{ print $4 }')"
    [ -z "$options" ] && return 1
    dump="$(echo "$line" | awk '{ print $5 }')"
    [ -z "$dump" ] && return 1
    pass="$(echo "$line" | awk '{ print $6 }')"
    [ -z "$pass" ] && return 1
    if [ "$rootdev_fstab" != "$rootdev" ]; then
     # change root partition if necessary
     echo "Setze Rootpartition: $rootdev."
     rootdev_fstab="$rootdev"
     line="$rootdev_fstab $mntpnt $fstype_fstab $options $dump $pass"
     changed=yes
    fi # rootdev
    # check for changed filesytem type if partition was formatted
    fstype_mount="$(cat /proc/mounts | grep "^$rootdev" | awk '{ print $3 }')"
    [ -z "$fstype_mount" ] && return 1
    if [ "$fstype_fstab" != "$fstype_mount" ]; then
     # change filesystem
     echo "Setze Dateisystem: $fstype_mount."
     fstype_fstab="$fstype_mount"
     line="$rootdev_fstab $mntpnt $fstype_fstab $options $dump $pass"
     changed=yes
    fi # fstype
   fi # mntpnt
  fi # line
  echo "$line" >> /tmp/fstab
 done </mnt/etc/fstab # reading fstab
 if [ -n "$changed" ]; then
  mv -f /mnt/etc/fstab /mnt/etc/fstab.bak
  mv -f /tmp/fstab /mnt/etc
 fi
}

# process opsi stuff if client is installed: do_opsi baseimage image
do_opsi(){
 # test for opsi's client config
 local conf
 conf="$(ls /mnt/[Pp][Rr][Oo][Gg][Rr][Aa][Mm]*/opsi.org/opsi-client-agent/opsiclientd/opsiclientd.conf 2> /dev/null)"
 [ -s "$conf" ] || return 0
 echo "Starte OPSI-Client-Konfiguration ..."
 local ip="$(grep ^ip /tmp/dhcp.log | awk -F\' '{ print $2 }')"
 local domainname="$(grep ^domain /tmp/dhcp.log | awk -F\' '{ print $2 }' | tail -1)"
 local fqdn="$(hostname).$domainname"
 local serverip="$(grep ^linbo_server /tmp/dhcp.log | tail -1 | awk -F\' '{ print $2 }')"
 local opsiip="${serverip/.1.1/.1.2}"
 local image
 local RC="0"
 if [ -n "$2" ]; then
  image="$2"
 else
  image="$1"
 fi
 # request opsikey
 rsync "$serverip"::linbo/"$ip.opsikey" /cache/opsikey
 [ -s /cache/opsikey ] && local key="$(cat /cache/opsikey)"
 if [ -n "$key" ]; then
  echo "Opsi-Host-Key heruntergeladen."
  # patch opsi host key
  sed -e "s|^host_id.*|host_id = $fqdn|" -e "s|^opsi_host_key.*|opsi_host_key = $key|" -i "$conf" || RC="1"
  # patch changed opsi ip
  if ! grep -q "$opsiip" "$conf"; then
   sed -e "s|10.*.1.2|$opsiip|g" -i "$conf" || RC="1"
  fi
  if [ "$RC" = "0" ]; then
   echo "Opsi-Clientkonfiguration aktualisiert."
  else
   echo "Opsi-Clientkonfiguration konnte nicht aktualisiert werden."
  fi
 else
  echo "Opsi-Host-Key konnte nicht heruntergeladen werden."
  RC="1"
 fi
 rm -f /cache/opsikey
 # request opsi host ini update
 rsync "$serverip"::linbo/"$image.opsi" /cache &> /dev/null || true
 return "$RC"
}

# restore windows activation tokens
restore_winact(){
 # get image name
 [ -s  /mnt/.linbo ] && local image="$(cat /mnt/.linbo)"
 # if an image is not yet created do nothing
 if [ -z "$image" ]; then
  echo "Überspringe Reaktivierung, System ist unsynchronisiert."
  return
 fi
 local archive
 local tarchive
 local i
 # get mac address
 local mac="$(mac | tr a-z A-Z)"
 # without linbo server
 if localmode || [ -z "$mac" ] || [ "$mac" = "OFFLINE" ]; then
  tarchive="$(cd /cache && ls *.$image.winact.tar.gz 2> /dev/null)"
  # get mac address from archive name
  for i in $tarchive; do
   mac="$(echo $i | awk -F\. '{ print $1 }')"
   if ifconfig -a | grep -q "$mac"; then
    archive="$i"
    break
   fi
  done
 else # with linbo server
  archive="$mac.$image.winact.tar.gz"
  # get token archive from linbo server
  echo "Fordere Reaktivierungs-Daten von $serverip an."
  # get server ip address
  local serverip="$(grep ^linbo_server /tmp/dhcp.log | tail -1 | awk -F\' '{ print $2 }')"
  rsync "$serverip"::linbo/winact/"$archive" /cache &> /dev/null
  # request windows/office productkeys
  local keyfile="$(ifconfig -a | md5sum | awk '{ print $1 }').winkey"
  rsync "$serverip"::linbo/winact/"$keyfile" /cache &> /dev/null
  [ -s "/cache/$keyfile" ] && source "/cache/$keyfile"
  # create windows key batchfile
  if [ -n "$winkey" ]; then
   echo "cscript.exe %SystemRoot%\\System32\\slmgr.vbs -ipk $winkey" > "/cache/$image.winact.cmd"
  fi
  # add office key handling to batchfile if office token is in archive
  if gunzip -c "/cache/$archive" | tar -t | grep -qi office; then
   if [ -n "$officekey" ]; then
    # get office installation dir
    local office_dir="$(ls -d /mnt/[Pp][Rr][Oo][Gg][Rr][Aa][Mm]\ [Ff][Ii][Ll][Ee][Ss]\ \(x86\)/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]\ [Oo][Ff][Ff][Ii][Cc][Ee]/[Oo][Ff][Ff][Ii][Cc][Ee]1[45] 2> /dev/null)"
    if [ -n "$office_dir" ]; then
     # compute windows path to office installation dir
     local office_win_dir="$(echo "$office_dir" | sed 's|/mnt/|%SystemDrive%\\|' | sed 's|/|\\|g' )"
     # write office activations commands to batchfile
     echo "cscript.exe \"$office_win_dir\\ospp.vbs\" /inpkey:$officekey" >> "/cache/$image.winact.cmd"
     echo "cscript.exe \"$office_win_dir\\ospp.vbs\" /act" >> "/cache/$image.winact.cmd"
    fi
   fi
  fi
  dos2unix "/cache/$image.winact.cmd"
  rm -f "$keyfile"
 fi
 # no data available
 if [ ! -s "/cache/$archive" -o ! -s "/cache/$image.winact.cmd" ]; then
  echo "Überspringe Reaktivierung, keine Daten."
  return
 fi
 echo "Stelle Windows-Aktivierungstokens wieder her."
 tar xf "/cache/$archive" -C / || return 1
 # copy batchfile
 local batchfile="/mnt/linuxmuster-win/winact.cmd"
 echo "Schreibe Aktivierungs-Batchdatei nach $batchfile."
 cp "/cache/$image.winact.cmd" "$batchfile"
}

# syncl cachedev baseimage image bootdev rootdev kernel initrd append [force]
syncl(){
 local RC=1
 local patchfile=""
 local postsync=""
 local rootdev="$5"
 local disk="${rootdev%%[1-9]*}"
 local group="$(hostgroup)"
 # don't sync in that case
 if [ "$1" = "$rootdev" ]; then
  echo "Ueberspringe lokale Synchronisation. Image $2 wird direkt aus Cache gestartet."
  return 0
 fi
 echo -n "syncl " ; printargs "$@"
 mountcache "$1" || return "$?"
 cd /cache
 local image=""
 for image in "$2" "$3"; do
  [ -n "$image" ] || continue
  if [ -f "$image" ]; then
   restore "$image" "$5" $9 ; RC="$?"
   [ "$RC" = "0" ] || break
   patchfile="$image.reg"
   postsync="$image.postsync"
  fi
 done
 if [ "$RC" = "0" ]; then
  # Apply patches
  if mountpart "$5" /mnt -w 2>> /tmp/linbo.log; then
   # hostname
   local HOSTNAME
   if localmode; then
    if [ -s /cache/hostname ]; then
     HOSTNAME="$(cat /cache/hostname)"
    fi
   fi
   [ -z "$HOSTNAME" ] && HOSTNAME="$(hostname)"
   # do registry patching for windows systems
   if [ -r "$patchfile" ]; then
    echo "Patche System mit $patchfile."
    rm -f "$TMP"
    sed 's|{\$HostName\$}|'"$HOSTNAME"'|g' "$patchfile" > "$TMP"
    dos2unix "$TMP"
    # tschmitt: different patching for different windows 
    # WinXP, Win7
    if [ -e /mnt/[Nn][Tt][Ll][Dd][Rr] -o -e /mnt/[Bb][Oo][Oo][Tt][Mm][Gg][Rr] ]; then
     # tschmitt: logging
     echo -n "Patche System mit $patchfile." >/tmp/patch.log
     cat "$TMP" >>/tmp/patch.log
     patch_registry "$TMP" /mnt 2>&1 >>/tmp/patch.log
     [ -e /tmp/output ] && cat /tmp/output >>/tmp/patch.log
    # Win98
    elif [ -e /mnt/[Ii][Oo].[Ss][Yy][Ss] ]; then
     cp -f "$TMP" /mnt/linbo.reg
     unix2dos /mnt/linbo.reg
    fi
    rm -f "$TMP"
   fi
   # tweak newdev.dll (suppresses new hardware dialog)
   local newdevdll="$(ls /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Nn][Ee][Ww][Dd][Ee][Vv].[Dd][Ll][Ll] 2> /dev/null)"
   [ -z "$newdevdll" ] && newdevdll="$(ls /mnt/[Ww][Ii][Nn][NN][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Nn][Ee][Ww][Dd][Ee][Vv].[Dd][Ll][Ll] 2> /dev/null)"
   local newdevdllbak="$newdevdll.linbo-orig"
   # save original file
   [ -n "$newdevdll" -a ! -e "$newdevdllbak" ] && cp "$newdevdll" "$newdevdllbak"
   # patch newdev.dll
   if [ -n "$newdevdll" ]; then
    echo "Patche $newdevdll."
    grep ^: /etc/newdev-patch.bvi | bvi "$newdevdll" 2>>/tmp/patch.log 1> /dev/null
   fi
   # restore win7 bcd
   [ -e /mnt/[Bb][Oo][Oo][Tt]/[Bb][Cc][Dd] ] && local bcd="$(ls /mnt/[Bb][Oo][Oo][Tt]/[Bb][Cc][Dd] 2> /dev/null)"
   [ -n "$bcd" ] && local groupbcd="$bcd"."$group"
   if [ -n "$groupbcd" -a -s "$groupbcd" ]; then
    echo "Restauriere /Boot/BCD."
    cp -f "$groupbcd" "$bcd"
   fi
   # restore win7 mbr flag
   [ -e /mnt/[Bb][Oo][Oo][Tt]/win7mbr."$group" ] && local mbr="$(ls /mnt/[Bb][Oo][Oo][Tt]/win7mbr."$group" 2> /dev/null)"
   if [ -n "$mbr" -a -s "$mbr" ]; then
    echo "Patche Win7-MBR."
    dd if=$mbr of=$disk bs=1 count=4 seek=440 2>> /tmp/linbo.log
   fi
   # restore ntfs id
   [ -e /mnt/[Bb][Oo][Oo][Tt]/ntfs.id ] && local ntfsid="$(ls /mnt/[Bb][Oo][Oo][Tt]/ntfs.id 2> /dev/null)"
   if [ -n "$ntfsid" -a -s "$ntfsid" ]; then
    echo "Restauriere NTFS-ID."
    dd if=$ntfsid of=$rootdev bs=8 count=1 seek=9 2>> /tmp/linbo.log
   fi 
   # write partition boot sector (vfat only)
   if [ "$(fstype "$5")" = "vfat" ]; then
    local msopt=""
    [ -e /mnt/[Nn][Tt][Ll][Dd][Rr] ] && msopt="-2"
    [ -e /mnt/[Ii][Oo].[Ss][Yy][Ss] ] && msopt="-3"
    if [ -n "$msopt" ]; then
     echo "Schreibe Partitionsbootsektor." | tee -a /tmp/patch.log
     ms-sys "$msopt" "$5" | tee -a /tmp/patch.log
    fi
   fi
   # patching for linux systems
   # hostname
   if [ -f /mnt/etc/hostname ]; then
    if [ -n "$HOSTNAME" ]; then
     echo "Setze Hostname -> $HOSTNAME."
     echo "$HOSTNAME" > /mnt/etc/hostname
    fi
   fi
   # copy ssh keys
   if [ -d /mnt/etc/dropbear ]; then
    cp /etc/dropbear/* /mnt/etc/dropbear
    if [ -s /mnt/root/.ssh/authorized_keys ]; then
     local sshkey="$(cat /.ssh/authorized_keys)"
     grep -q "$sshkey" /mnt/root/.ssh/authorized_keys || cat /.ssh/authorized_keys >> /mnt/root/.ssh/authorized_keys
    else
     mkdir -p /mnt/root/.ssh
     cp /.ssh/authorized_keys /mnt/root/.ssh
    fi
    chmod 600 /mnt/root/.ssh/authorized_keys
   fi
   # patch dropbear config with port 2222 and disable password logins
   if [ -s /mnt/etc/default/dropbear ]; then
    sed -e 's|^NO_START=.*|NO_START=0|
            s|^DROPBEAR_EXTRA_ARGS=.*|DROPBEAR_EXTRA_ARGS=\"-s -g\"|
            s|^DROPBEAR_PORT=.*|DROPBEAR_PORT=2222|' -i /mnt/etc/default/dropbear
   fi
   # fstab
   [ -f /mnt/etc/fstab ] && patch_fstab "$rootdev"
   # do opsi stuff
   do_opsi "$2" "$3" || RC="1"
   # restore windows activation if linuxmuster-win scripts are installed
   if [ -e /mnt/[Bb][Oo][Oo][Tt][Mm][Gg][Rr] -a -d /mnt/linuxmuster-win ]; then
    restore_winact || RC="1"
   fi
   # source postsync script
   [ -s "/cache/$postsync" ] && . "/cache/$postsync"
   sync; sync; sleep 1
   umount /mnt || umount -l /mnt
  fi
 fi
 sendlog
 cd / # ; mountcache "$1" -r
 return "$RC"
}

# create cachedev imagefile baseimagefile bootdev rootdev kernel initrd
create(){
 echo -n "create " ;  printargs "$@"
 [ -n "$2" -a -n "$1" -a -n "$5" ] || return 1
 mountcache "$1" || return "$?"
 if ! cache_writable; then
  echo "Cache-Partition ist nicht schreibbar, Abbruch." >&2 | tee -a /tmp/image.log
  sendlog
  mountcache "$1" -r
  return 1
 fi
 cd /cache
 local RC="1"
 local type="$(fstype "$5")"
 echo "Erzeuge Image '$2' von Partition '$5'..." | tee -a /tmp/image.log
 case "$2" in
  *.[Cc][Ll][Oo]*)
   mk_cloop partition "$5" "$2" "$3" ; RC="$?"
   ;;
  *.[Rr][Ss][Yy]*)
    mk_cloop differential "$5" "$2" "$3" ; RC="$?"
   ;;
 esac
 [ "$RC" = "0" ] && echo "Fertig." || echo "Fehler." >&2
 sendlog
 cd / ; mountcache "$1" -r
 return "$RC"
}

# getinfo file key
getinfo(){
 [ -f "$1" ] || return 1
 while read line; do
  local key="${line%%=*}"
  if [ "$key" = "$2" ]; then
   echo "${line#*=}"
   return 0
  fi
 done <"$1"
 return 1
}

# mk_info imagename baseimagename device_size image_size - creates timestamp file
mk_info(){
 echo "[$1 Info File]
timestamp=$(date +%Y%m%d%H%M)
image=$1
baseimage=$2
partitionsize=$3
imagesize=$4"
}

# get_multicast_server file
get_multicast_server(){
 local file=""
 local serverport=""
 local relax=""
 while read file serverport relax; do
  if [ "$file" = "$1" ]; then
   echo "${serverport%%:*}"
   return 0
  fi
 done </multicast.list
 return 1
}

# get_multicast_port file
get_multicast_port(){
 local file=""
 local serverport=""
 local relax=""
 while read file serverport relax; do
  if [ "$file" = "$1" ]; then
   echo "${serverport##*:}"
   return 0
  fi
 done </multicast.list
 return 1
}

# download_multicast server port file
download_multicast(){
 local interface="$(route -n | grep ^0.0.0.0 | awk '{print $NF}')"
 echo "MULTICAST Download $interface($1):$2 -> $3"
 echo "udp-receiver --log /tmp/image.log --nosync --nokbd --interface $interface --rcvbuf 4194304 --portbase $2 --file $3"
 interruptible udp-receiver --log /tmp/image.log --nosync --nokbd --interface "$interface" --rcvbuf 4194304 --portbase "$2" --file "$3" 2>&1 ; RC="$?"
 return "$RC"
}

# torrent_watchdog image timeout
torrent_watchdog(){
 local image="$1"
 local complete="$image".complete
 local torrent="$image".torrent
 local logfile=/tmp/"$image".log
 local timeout="$2"
 local line=""
 local line_old=""
 local int=10
 local RC=1
 local c=0
 while [ $c -lt $timeout ]; do
  sleep $int
  # check if torrent is complete
  [ -e "$complete" ] && { RC=0; break; }
  line="$(tail -1 "$logfile" | awk '{ print $3 }')"
  [ -z "$line_old" ] && line_old="$line"
  if [ "$line_old" = "$line" ]; then
   [ $c -eq 0 ] || echo -e "\nTorrent-Watchdog: Download von $image stockt seit $c Sekunden." >&2 | tee -a /tmp/image.log
   c=$(($c+$int))
  else
   line_old="$line"
   c=0
  fi
 done
 rm -f "$logfile"
 echo
 if [ "$RC" = "0" ]; then
  echo "Image $image erfolgreich heruntergeladen." | tee -a /tmp/image.log
 else
  ps w | grep -v grep | grep -q ctorrent && killall -9 ctorrent
  echo "Download von $image wegen Zeitüberschreitung abgebrochen." >&2 | tee -a /tmp/image.log
 fi
 return "$RC"
}

# download_torrent image
download_torrent(){
 local image="$1"
 local torrent="$image".torrent
 local complete="$image".complete
 local RC=1
 [ -e "$torrent" ] || return "$RC"
 local ip="$(ip)"
 [ -z "$ip" -o "$ip" = "OFFLINE" ] && return "$RC"
 # default values
 local MAX_INITIATE=40
 local MAX_UPLOAD_RATE=0
 local SLICE_SIZE=128
 local TIMEOUT=300
 [ -e /torrent-client.conf ] && . /torrent-client.conf
 [ -n "$DOWNLOAD_SLICE_SIZE" ] && SLICE_SIZE=$(($DOWNLOAD_SLICE_SIZE/1024))
 local pid="$(ps w | grep ctorrent | grep "$torrent" | grep -v grep | awk '{ print $1 }')"
 [ -n "$pid" ] && kill "$pid"
 local OPTS="-e 100000 -I $ip -M $MAX_INITIATE -z $SLICE_SIZE"
 [ $MAX_UPLOAD_RATE -gt 0 ] && OPTS="$OPTS -U $MAX_UPLOAD_RATE"
 echo "Torrent-Optionen: $OPTS" >> /tmp/image.log
 echo "Starte Torrent-Dienst für $image." | tee -a /tmp/image.log
 local logfile=/tmp/"$image".log
 if [ ! -e "$complete" ]; then
  rm -f "$image" "$torrent".bf
  torrent_watchdog "$image" "$TIMEOUT" &
  interruptible ctorrent $OPTS -X "touch $complete ; killall -9 ctorrent" "$torrent" | tee -a "$logfile"
 fi
 [ -e "$complete" ] && RC=0
 for i in *.torrent; do
  # start seeders
  [ -e "${i/.torrent/.complete}" ] && ctorrent -f -d $OPTS "$i"
 done
 return "$RC"
}

# Download main file and supplementary files
# download_all server mainfile additional_files...
download_all(){
 local RC=0
 local server="$1"
 download "$server" "$2" important; RC="$?"
 if [ "$RC" != "0" ]; then
  rm -f "$2"
  return "$RC"
 fi
 shift; shift;
 local file=""
 for file in "$@"; do
  download "$server" "$file"
 done
 return "$RC"
}

# Download info files, compare timestamps
# download_if_newer server file downloadtype
download_if_newer(){
 # do not execute in localmode
 localmode && return 0
 local DLTYPE="$3"
 [ -z "$DLTYPE" ] && DLTYPE="$(downloadtype)"
 [ -z "$DLTYPE" ] && DLTYPE="rsync"
 local RC=0
 local DOWNLOAD_ALL=""
 local IMAGE=""
 case "$2" in *.[Cc][Ll][Oo][Oo][Pp]|*.[Rr][Ss][Yy][Nn][Cc]) IMAGE="true" ;; esac
 if [ ! -s "$2" -o ! -s "$2".info ]; then # File not there, download all
  DOWNLOAD_ALL="true"
 else
  mv -f "$2".info "$2".info.old 2>/dev/null
  download "$1" "$2".info
  if [ -s "$2".info ]; then
   local ts1="$(getinfo "$2".info.old timestamp)"
   local ts2="$(getinfo "$2".info timestamp)"
   local fs1="$(getinfo "$2".info imagesize)"
   local fs2="$(get_filesize "$2")"
   if [ -n "$ts1" -a -n "$ts2" -a "$ts1" -gt "$ts2" ] >/dev/null 2>&1; then
    DOWNLOAD_ALL="true"
    echo "Server enthält eine neuere ($ts2) Version von $2 ($ts1)."
   elif  [ -n "$fs1" -a -n "$fs2" -a ! "$fs1" -eq "$fs2" ] >/dev/null 2>&1; then
    DOWNLOAD_ALL="true"
    echo "Dateigröße von $2 ($fs1) im Cache ($fs2) stimmt nicht."
   fi
   rm -f "$2".info.old
  else
   DOWNLOAD_ALL="true"
   mv -f "$2".info.old "$2".info
  fi
 fi
 # check for complete flag
 [ -z "$DOWNLOAD_ALL" -a -n "$IMAGE" -a ! -e "$2.complete" ] && DOWNLOAD_ALL="true"
 # supplemental torrent check
 if [ -n "$IMAGE" ]; then
  # save local torrent file
  [ -e "$2.torrent" -a -z "$DOWNLOAD_ALL" ] && mv "$2".torrent "$2".torrent.old
  # download torrent file from server
  download_all "$1" "$2".torrent ; RC="$?"
  if [ "$RC" != "0" ]; then
   echo "Download von $2.torrent fehlgeschlagen." >&2
   return "$RC"
  fi
  # check for updated torrent file
  if [ -e "$2.torrent.old" ]; then
   cmp "$2".torrent "$2".torrent.old || DOWNLOAD_ALL="true"
   rm "$2".torrent.old
  fi
  # update regpatch and postsync script
  rm -rf "$2".reg "$2".postsync
  download_all "$1" "$2".reg "$2".postsync >/dev/null 2>&1
 fi
 # start torrent service for others if there is no image to download
 [ "$DLTYPE" = "torrent" -a -n "$IMAGE" -a -z "$DOWNLOAD_ALL" ] && download_torrent "$2"
 # download because newer file exists on server
 if [ -n "$DOWNLOAD_ALL" ]; then
  if [ -n "$IMAGE" ]; then
   # remove complete flag
   rm -f "$2".complete
   # download images according to downloadtype torrent or multicast
   case "$DLTYPE" in
    torrent)
     # remove old image and torrents before download starts
     rm -f "$2" "$2".torrent.bf
     download_torrent "$2" ; RC="$?"
     [ "$RC" = "0" ] ||  echo "Download von $2 per torrent fehlgeschlagen!" >&2
    ;;
    multicast)
     if [ -s /multicast.list ]; then
      local MPORT="$(get_multicast_port "$2")"
      if [ -n "$MPORT" ]; then
       download_multicast "$1" "$MPORT" "$2" ; RC="$?"
      else
       echo "Konnte Multicast-Port nicht bestimmen, kein Multicast-Download möglich." >&2
       RC=1
      fi
     else
      echo "Datei multicast.list nicht gefunden, kein Multicast-Download möglich." >&2
      RC=1
     fi
     [ "$RC" = "0" ] || echo "Download von $2 per multicast fehlgeschlagen!" >&2
    ;;
   esac
   # download per rsync also as a fallback if other download types failed
   if [ "$RC" != "0" -o "$DLTYPE" = "rsync" ]; then
    [ "$RC" = "0" ] || echo "Versuche Download per rsync." >&2
    download_all "$1" "$2" ; RC="$?"
    [ "$RC" = "0" ] || echo "Download von $2 per rsync fehlgeschlagen!" >&2
   fi
   # download supplemental files and set complete flag if image download was successful
   if [ "$RC" = "0" ]; then
    # reg und postsync were downloaded already above
#    download_all "$1" "$2".info "$2".desc "$2".reg "$2".postsync >/dev/null 2>&1
    download_all "$1" "$2".info "$2".desc >/dev/null 2>&1
    touch "$2".complete
   fi
  else # download other files than images
   download_all "$1" "$2" "$2".info ; RC="$?"
   [ "$RC" = "0" ] || echo "Download von $2 fehlgeschlagen!" >&2
  fi
 else # download nothing, no newer file on server
  echo "Keine neuere Version vorhanden, überspringe $2."
 fi
 return "$RC"
}

# Authenticate server user password share
authenticate(){
 local RC=1
 localmode ; RC="$?"
 if [ "$RC" = "1" ]; then
  export RSYNC_PASSWORD="$3"
  echo "Logge $2 ein auf $1..."
  rm -f "$TMP"
  rsync "$2@$1::linbo-upload" >/dev/null 2>"$TMP" ; RC="$?"
 elif [ -e /etc/linbo_passwd ]; then
  echo "Authentifiziere offline ..."
  md5passwd="$(echo -n "$3" | md5sum | awk '{ print $1 }')"
  linbo_md5passwd="$(cat /etc/linbo_passwd)"
  if [ "$md5passwd" = "$linbo_md5passwd" ]; then
   RC=0
  else
   echo 'Passt nicht!' >"$TMP" ; RC=1
  fi
 else
  echo 'Kann nicht lokal authentifizieren!' >"$TMP" ; RC=1
 fi
 if [ "$RC" != "0" ]; then
  echo "Fehler: $(cat "$TMP")" >&2
  echo "Falsches Passwort oder fehlende Passwortdatei?" >&2
 else
  echo "Passwort OK."
  # temporary workaround for password
  echo -n "$RSYNC_PASSWORD" > /tmp/linbo.passwd
 fi
 rm -f "$TMP"
 return "$RC"
}

# upload server user password cache file
upload(){
 # do not execute in localmode
 localmode && return 0
 local RC=0
 local file
 local ext
 if remote_cache "$4"; then
  echo "Cache $4 ist nicht lokal, die Datei $5 befindet sich" | tee -a /tmp/linbo.log
  echo "höchstwahrscheinlich bereits auf dem Server, daher kein Upload." | tee -a /tmp/linbo.log
  sendlog
  return 1
 fi
 # We may need this password for mountcache as well!
 export RSYNC_PASSWORD="$3"
 mountcache "$4" || return "$?"
 cd /cache
 if [ -s "$5" ]; then
  local FILES="$5"
  # file list is obsolete
  #for ext in info list reg desc torrent; do
  for ext in info reg desc torrent; do
   [ -s "${5}.${ext}" ] && FILES="$FILES ${5}.${ext}"
  done
  echo "Uploade $FILES auf $1..." | tee -a /tmp/linbo.log
  for file in $FILES; do
   interruptible rsync --log-file=/tmp/rsync.log --progress -Ha $RSYNC_PERMISSIONS --partial "$file" "$2@$1::linbo-upload/$file"
   # because return code is always 0 this is necessary
   grep -q "rsync error" /tmp/rsync.log && RC=1
   cat /tmp/rsync.log >> /tmp/linbo.log
   rm /tmp/rsync.log
   if [ "$RC" != "0" ]; then
    break
   else
    # start torrent service for image
    case "$file" in
     *.torrent) ps w | grep ctorrent | grep "$file" | grep -v grep || download_torrent "${file%.torrent}" ;;
    esac
   fi
   #rm -f "$TMP"
  done
 else
  RC=1
  echo "Die Datei $5 existiert nicht, und kann daher nicht hochgeladen werden." | tee -a /tmp/linbo.log
 fi
 if [ "$RC" = "0" ]; then
  echo "Upload von $FILES nach $1 erfolgreich." | tee -a /tmp/linbo.log
 else
  echo "Upload von $FILES nach $1 ist fehlgeschlagen." | tee -a /tmp/linbo.log
 fi
 sendlog 
 cd / ; mountcache "$4" -r
 [ "$RC" = "0" ] && echo "Upload von $FILES nach $1 erfolgreich." || echo "Upload von $FILES nach $1 ist fehlgeschlagen." >&2
 return "$RC"
}

# Sync from server
# syncr server cachedev baseimage image bootdev rootdev kernel initrd append [force]
syncr(){
 echo -n "syncr " ; printargs "$@"
 if remote_cache "$2"; then
  echo "Cache $2 ist nicht lokal, überspringe Aktualisierung der Images."
 else
  mountcache "$2" || return "$?"
  cd /cache
  local i
  for i in "$3" "$4"; do
   [ -n "$i" ] && download_if_newer "$1" "$i"
  done
  sendlog
  cd / ; mountcache "$2" -r
  # Also update LINBO, while we are here.
  update "$1" "$2"
 fi
 shift 
 syncl "$@"
}

# update server cachedev 
update(){
 echo -n "update " ;  printargs "$@"
 local RC=0
 local group="$(hostgroup)"
 local server="$1"
 local cachedev="$2"
 local disk="${cachedev%%[1-9]*}"
 mountcache "$cachedev" || return 1
 cd /cache
 local kernel="$(kerneltype)"
 local kernelfs="$(kernelfstype)"

 # local restore of start.conf in cache (necessary if cache partition was formatted before)
 [ -s start.conf ] || cp /start.conf .
 echo "Aktualisiere LINBO-Kernel($kernel,$kernelfs)."
 download "$server" "$kernel" || RC=1
 download "$server" "$kernelfs" || RC=1
 # grub update
 if [ -s "$kernel" -a -s "$kernelfs" ]; then
  mkdir -p /cache/boot/grub
  # only if online
  if ! localmode; then
   # fetch pxe kernel
   download "$server" "gpxe.krn"
   # tschmitt: provide custom local menu.lst
   download "$server" "menu.lst.$group"
   if [ -e "/cache/menu.lst.$group" ]; then
    mv "/cache/menu.lst.$group" /cache/boot/grub/menu.lst || RC=1
    # flag for downloaded custom menu.lst
    touch /cache/.custom.menu.lst
   else
    rm -f /cache/.custom.menu.lst
   fi
  fi # localmode
  mkgrub || RC=1
 fi
 cd / ; sendlog
 #umount /cache
 if [ "$RC" = "0" ]; then
  echo "LINBO update fertig."
 else
  echo "Lokale Installation von LINBO hat nicht geklappt." >&2
 fi
 return "$RC"
}

# initcache server cachedev downloadtype images...
initcache(){
 # do not execute in localmode
 localmode && return 0
 echo -n "initcache " ;  printargs "$@"
 local server="$1"
 local cachedev="$2"
 local download_type="$3"
 local i
 local u
 local used_images
 local group
 local found
 if remote_cache "$cachedev"; then
  echo "Cache $cachedev ist nicht lokal, und muss daher nicht aktualisiert werden."
  return 1
 fi
 if [ -n "$FORCE_FORMAT" ]; then
  local cachefs="$(fstype_startconf "$cachedev")"
  if [ -n "$cachefs" ]; then
   echo "Formatiere Cache-Partition $cachedev..."
   format "$cachedev" "$cachefs" 2>> /tmp/linbo.log
  fi
 fi
 mountcache "$cachedev" || return "$?"
 cd /cache
 shift; shift; shift

 # clean up obsolete linbofs files
 rm -f linbofs[.a-zA-Z0-9_-]*.gz*
 rm -f linbo*.info

 # clean up obsolete image files
 used_images="$(grep -i ^baseimage /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }')"
 used_images="$used_images $(grep -i ^image /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }')"
 for i in *.cloop *.rsync; do
  [ -e "$i" ] || continue
  found=0
  for u in $used_images; do
   if [ "$i" = "$u" ]; then
    found=1
    break
   fi
  done
  if [ "$found" = "0" ]; then
   echo "Entferne nicht mehr benötigte Imagedatei $i." | tee -a /tmp/image.log
   rm -f "$i" "$i".*
  fi
 done

 # update cache files
 for i in "$@"; do
  if [ -n "$i" ]; then
   download_if_newer "$server" "$i" "$download_type"
  fi
 done
 # obsolete, done in update() anyway
 #sendlog
 #cd / ; mountcache "$cachedev" -r
 update "$server" "$cachedev"
}

### Main ###
# DEBUG linbo_gui:
# echo -n "Running: $cmd "
# count=1
# for i in "$@"; do
#  echo -n "$((count++))=$i,"
# done
# echo ""
# sleep 1

# readfile cachepartition filename [destinationfile]
readfile(){
 local RC=0
 mountcache "$1" || return "$?"
 if [ -n "$3" ]; then
  cp -a /cache/"$2" "$3"
 else
  cat /cache/"$2"
 fi
 RC="$?"
 #sendlog
 #umount /cache
 return "$RC"
}

# writefile cachepartition filename [sourcefile]
writefile(){
 local RC=0
 mountcache "$1" -w || return "$?"
 if cache_writable; then
  if [ -n "$3" ]; then
   cp -a "$3" /cache/"$2"
  else
   cat > /cache/"$2"
  fi
  RC="$?"
 else
  echo "Cache ist nicht schreibbar, Datei $2 nicht gespeichert." >&2
  RC=1
 fi
 #sendlog
 mountcache "$1" -r
 return "$RC"
}

# ready - check if LINBO is ready (timeout 120 seconds)
ready(){
 # Files /tmp/linbo-network.done and /tmp/linbo-cache.done created by init.sh
 local count=0
 while [ ! -e /tmp/linbo-network.done -o ! -e /tmp/linbo-cache.done -o ! -s start.conf ]; do
  sleep 1
#  echo -n "."
  count=`expr $count + 1`
  if [ "$count" -gt 120 ]; then
   echo "Timeout, LINBO not ready. :-(" >&2
   return 1
  fi
 done
 localmode || echo "Network OK."
 echo "Local Disk(s) OK."
 return 0
}

mac(){
 local iface="$(grep eth /proc/net/route | sort | head -n1 | awk '{print $1}')"
 local mac="$(LANG=C ifconfig "$iface" | grep HWaddr | awk '{print $5}' | tr a-z A-Z)"
 [ -z "$mac" ] && mac="OFFLINE"
 echo "$mac"
}

# register server user password variables...
register(){
 local RC=1
 local room="$4"
 local client="$5"
 local ip="$6"
 local group="$7"
 local macaddr="$(mac)"
 [ "$maccaddr" = "OFFLINE" ] && return 1
 local info="$room;$client;$group;$macaddr;$ip;255.240.0.0;1;1;1;1;1"
 # Plausibility check
 if echo "$client" | grep -qi '[^a-z0-9-]'; then
  echo "Falscher Rechnername: '$client'," >&2
  echo "Rechnernamen dürfen nur Buchstaben [a-z0-9-] enthalten." >&2
  return 1
 fi
 if echo "$group" | grep -qi '[^a-z0-9_]'; then
  echo "Falscher Gruppenname: '$group'," >&2
  echo "Rechnergruppen dürfen nur Buchstaben [a-z0-9_] enthalten." >&2
  return 1
 fi
 cd /tmp
 echo "$info" '>' "$client.new"
 echo "$info" >"$client.new"
 echo "Uploade $client.new auf $1..."
 export RSYNC_PASSWORD="$3"
 interruptible rsync --progress -HaP "$client.new" "$2@$1::linbo-upload/$client.new" ; RC="$?"
 cd /
 return "$RC"
}

ip(){
 local ip="$(ifconfig "$(grep eth /proc/net/route | sort | head -n1 | awk '{print $1}')" | grep 'inet\ addr' | awk '{print $2}' | awk 'BEGIN { FS = ":" }; {print $2}')" # fix syntax highlighting "
 [ -z "$ip" ] && ip="OFFLINE"
 echo "$ip"
}

clientname(){
 local clientname="$(hostname)"
 if localmode; then
  local cachedev="$(grep ^Cache /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }')"
  if [ -b "$cachedev" ]; then
   if mountcache $cachedev -r &> /dev/null; then
    if [ -s /cache/hostname ]; then
     clientname="$(cat /cache/hostname)"
    fi
   fi
  fi
 fi
 echo "$clientname"
}

cpu(){
 cat /proc/cpuinfo | grep name | sed 's,model.*:\ ,,'
}

memory(){
 free | grep Mem | awk '{printf "%d MB\n",$2 / 1024}'
}

size(){
 if mountpart "$1" /mnt -r 2>> /tmp/linbo.log; then
  df -k /mnt 2>/dev/null | tail -1 | \
   awk '{printf "%.1f/%.1fGB\n", $4 / 1048576, $2 / 1048576}' 2>/dev/null
  umount /mnt
 else
  local d=$(sfdisk -s $1 2>> /tmp/linbo.log)
  if [ "$?" = "0" -a "$d" -ge 0 ] 2>/dev/null; then
   echo "$d" | awk '{printf "%.1fGB\n",$1 / 1048576}' 2>/dev/null
  else
   echo " -- "
  fi
 fi
 return 0
}

#
# jweiher, angepasst tschmitt
# Ermittelt den logisch naechsten Hostnamen, um die Rechneraufnahme zu
# erleichtern
#
preregister() {
 local LAST_REGISTERED="/tmp/last_registered"
 interruptible rsync --progress -HaP "$1::linbo/last_registered" "$LAST_REGISTERED" ; RC="$?"
 local LASTWORKSTATION="$(grep ^[a-z0-9] "$LAST_REGISTERED" | tail -n 1)"

 if [ "$LASTWORKSTATION" == "" ]; then
  echo ",,," > /tmp/newregister
  rm -f "$LAST_REGISTERED"
  return 0
 fi

 local LASTGROUP="$(echo $LASTWORKSTATION | cut -d ";" -f 3)"
 local LASTROOM="$(echo $LASTWORKSTATION | cut -d ";" -f 1)"
 local LASTHOST="$(echo $LASTWORKSTATION | cut -d ";" -f 2)"
 local LASTIP="$(echo $LASTWORKSTATION | cut -d ";" -f 5)"

 # Naechste IP ermitteln
 local NEXTIP="$(echo -n $LASTIP | cut -d "." -f 1-3).$(($(echo $LASTIP | cut -d "." -f 4)+1))"

 # Naechsten Hostnamen ermitteln
 local HOSTNAMECOUNTER="$(echo $LASTHOST | grep -Eo "[0-9]+$")"
 local NEXTCOUNT
 if [ ! "$HOSTNAMECOUNTER" == "" ]; then
  NEXTCOUNT=$(expr $HOSTNAMECOUNTER + 1)
  # Left fill with zeroes
  while [ "${#NEXTCOUNT}" -lt "${#HOSTNAMECOUNTER}" ]; do
   NEXTCOUNT=0$NEXTCOUNT
  done

  # Build new hostname
  local NEXTHOST="$(echo -n $LASTHOST | sed "s/${HOSTNAMECOUNTER}$//g")$NEXTCOUNT"
 else
  NEXTHOST="$LASTHOST"
 fi
 rm -f "$LAST_REGISTERED"
 echo "$LASTROOM,$LASTGROUP,$NEXTHOST,$NEXTIP" > /tmp/newregister
 return 0
}

version(){
 local versionfile="/etc/linbo-version"
 if [ -s "$versionfile" ]; then
  cat "$versionfile"
 else
  echo "LINBO 2.x"
 fi
}

# Main

case "$cmd" in
 ip) ip ;;
 hostname) clientname ;;
 cpu) cpu ;;
 memory) memory ;;
 mac) mac ;;
 size) size "$@" ;;
 authenticate) authenticate "$@" ;;
 create) create "$@" ;;
 start) start "$@" ;;
 partition_noformat) export NOFORMAT=1; partition "$@" ;;
 partition) partition "$@" ;;
 preregister) preregister "$@";;
 initcache) initcache "$@" ;;
 initcache_format) echo "initcache_format gestartet."; export FORCE_FORMAT=1; initcache "$@" ;;
 mountcache) mountcache "$@" ;;
 readfile) readfile "$@" ;;
 ready) ready "$@" ;;
 register) register "$@" ;;
 sync) syncl "$@" && { cache="$1"; shift 3; start "$1" "$2" "$3" "$4" "$5" "$cache"; } ;;
 syncstart) syncr "$@" && { cache="$2"; shift 4; start "$1" "$2" "$3" "$4" "$5" "$cache"; } ;;
 syncr) syncr "$@" && { cache="$2"; shift 4; start "$1" "$2" "$3" "$4" "$5" "$cache"; } ;;
 synconly) syncr "$@" ;;
 update) update "$@" ;;
 upload) upload "$@" ;;
 version) version ;;
 writefile) writefile "$@" ;;
 *) help "$cmd" "$@" ;;
esac

# Return returncode
exit "$?"
