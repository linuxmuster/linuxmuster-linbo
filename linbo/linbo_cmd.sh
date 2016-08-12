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
# 20160804
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
 echo "Moeglicher Fehler erkannt: linbo_cmd laeuft bereits." >> /tmp/linbo.log
 #cat "$TMP" >&2
 cat "$TMP" >> /tmp/linbo.log
fi
rm -f "$TMP"
# EOF Debugging

# set terminal & PATH
export TERM=xterm
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

printargs(){
 local arg
 local count=1
 for arg in "$@"; do
  echo -n "$((count++)): »$arg« "
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
 local i
 for i in patch.log image.log linbo.log; do
  logfile="/tmp/$i"
  if [ -s "$logfile" ]; then
   if localmode; then
    if cache_writable; then
     echo "Speichere Logdatei $i im Cache."
     cp "$logfile" /cache
    fi
   else
    [ -e /tmp/linbo-network.done ] || return 0
    echo "Veranlasse Upload von $i."
    logfile="/tmp/$(hostname)_$i"
    rsync $(serverip)::linbo"$logfile" "/tmp/$i" 2>"$TMP" || true
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
 echo "DEBUG: bailout() aufgerufen, linbo_cmd=$PID, my_pid=$$" >&2
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
 Ungueltiger LINBO-Befehl: »$@«

 Syntax: linbo_cmd command option1 option2 ...

 Beispiele:
 start bootdev rootdev kernel initrd append
               - Fahre Betriebssystem hoch
 syncr server  cachedev baseimage image bootdev rootdev kernel initrd
               - Synchronisiere Cache vom Server, dann Partitionen vom Cache
 syncl cachedev baseimage image bootdev rootdev kernel initrd
               - Synchronisiere Partitionen vom Cache

 Image-Arten:
 .cloop - Image vom kompletten Blockgeraet (block device, z.B. Partition), CLOOP-komprimiert
 .rsync - Differentielles RSYNC-Abbild, CLOOP-komprimiert
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

# cachedev: prints cache device from start.conf
cachedev(){
 [ -s /start.conf ] || return 1
 grep -iw ^cache /start.conf | awk -F\# '{ print $1 }' | awk -F\= '{ print $2 }' | awk '{ print $1 }' | tail -1
}

# serverip: prints server ip from start.conf
serverip(){
 [ -s /start.conf ] || return 1
 grep -iw ^server /start.conf | awk -F\# '{ print $1 }' | awk -F\= '{ print $2 }' | awk '{ print $1 }' | tail -1
}

# tschmitt
# fetch osname from start.conf
# args: rootpartition
osname(){
 [ ! -b "$1" -o ! -s /start.conf ] && return 1
 local partition="$1"
 local osname
 local rootpart
 local value
 local line
 grep -iw ^[rn][oa][om][te] /start.conf | awk -F\# '{ print $1 }' | while read line; do
  value="$(echo "$line" | awk -F\= '{ print $2 }' | sed -e 's|^ *||')"
  case "$line" in
   [Nn][Aa][Mm][Ee]*) osname="$value" ;;
   [Rr][Oo][Oo][Tt]*) rootpart="$value" ;;
  esac
  if [ -n "$osname" -a -n "$rootpart" ]; then
   if [ "$rootpart" = "$partition" ]; then
    echo "$osname"
    return 0
   fi
   osname=""
   rootpart=""
  fi
 done
 return 1
}

# print kernel options from start.conf
kerneloptions(){
 [ -s /start.conf ] || return 1
 grep -i ^kerneloptions /start.conf | tail -1 | sed -e 's/#.*$//' -e 's/kerneloptions//I' | awk -F\= '{ print substr($0, index($0,$2)) }' | sed -e 's/ =//' -e 's/^ *//g' -e 's/ *$//g'
}

# fschuett
# fetch SystemType from start.conf
systemtype(){
 local systemtype="bios"
 [ -s /start.conf ] || return 1
 systemtype=`grep -iw ^SystemType /start.conf | tail -1 | awk -F= '{ print $2 }' | awk '{ print $1 }'`
 echo "$systemtype"
}

get_64(){
 local is_64=""
 uname -a | grep -q x86_64 && is_64="64"
 echo "$is_64"
}


# fschuett
# extract block device name for sd?,/dev/sd?,*blk?p?,/dev/*blk?p?
# get_disk_from_partition partition
get_disk_from_partition(){
  local p="$1"
  local disk=
  expr "$p" : ".*p[[:digit:]][[:digit:]]*" >/dev/null && disk=${p%%p[0-9]*}
  expr "$p" : ".*[hsv]d[[:alpha:]][[:digit:]][[:digit:]]*" >/dev/null && disk=${p%%[0-9]*}
  if [ -n "$disk" ]; then
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
   if [ -z "$disks" ]; then
    disks="$(get_disk_from_partition "$p")"
   else
    disks="$disks $(get_disk_from_partition "$p")"
   fi
  done;
  disks="$(echo $disks|tr " " "\n" | sort -u)"
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
    echo "CLOOP-Device ist noch nicht verfuegbar, versuche erneut..."
    wmsg=1
    sleep 2
   fi
  done
  if [ ! -b /dev/cloop0 ]; then
   echo "CLOOP-Device ist nicht bereit! Breche ab!"
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
 case "$1" in *:*|*//*|*\\*|*\\\\*) return 0 ;; esac
 return 1
}

# format partition fstype label
format(){
 #echo -n "format " ;  printargs "$@"
 local partition="$1"
 local fstype="$2"
 local label="$3"
 local cmd
 local RC
 if [ -n "$label" ]; then
  case "$fstype" in
   swap) cmd="mkswap -L $label $partition" ;;
   reiserfs) cmd="mkreiserfs -l $label -f -f  $partition" ;;
   ext2|ext3|ext4) cmd="mkfs.$fstype -L $label $partition" ;;
   [Nn][Tt][Ff][Ss]*) cmd="mkfs.ntfs -L $label -Q $partition" ;;
   *[Ff][Aa][Tt]*) cmd="mkdosfs -n $label -F 32 $partition" ;;
   *) return 1 ;;
  esac
 else
  case "$fstype" in
   swap) cmd="mkswap $partition" ;;
   reiserfs) cmd="mkreiserfs -f -f  $partition" ;;
   ext2|ext3|ext4) cmd="mkfs.$fstype $partition" ;;
   [Nn][Tt][Ff][Ss]*) cmd="mkfs.ntfs -Q $partition" ;;
   *[Ff][Aa][Tt]*) cmd="mkdosfs -F 32 $partition" ;;
   *) return 1 ;;
  esac
 fi
 echo -n "Formatiere $partition mit $fstype ..."
 [ -d "$partition" ] || sleep 5
 $cmd 2>> /tmp/linbo.log 1>> /tmp/linbo.log ; RC="$?"
 if [ "$RC" != "0" ]; then
  echo -n " Partition ist noch nicht bereit - versuche nochmal ..."
  sleep 2
  $cmd 2>> /tmp/linbo.log 1>> /tmp/linbo.log ; RC="$?"
 fi
 if [ "$RC" = "0" ]; then
  echo " OK!"
  # install linbo and grub in cache
  local cachedev="$(cachedev)"
  if [ "$cachedev" = "$partition" ]; then
   rm -f /tmp/.update.done
   rm -f /tmp/.grub-install
   rm -f /tmp/.prepare_grub
   update "$(serverip)" "$cachedev"
   mk_boot
   if mountcache "$cachedev"; then
    echo "Speichere start.conf auf Cache."
    cp /start.conf /cache
    # save hostname for offline use
    echo "Speichere Hostnamen $(hostname) auf Cache."
    hostname > /cache/hostname
   fi
  fi
 else
  echo " Fehler!"
 fi
 return "$RC"
}

# mountcache partition [options]
mountcache(){
 local RC=1
 [ -n "$1" ] || return 1
 export CACHE_PARTITION="$1"
 # Avoid duplicate mounts by just preparing read/write mode
 local mount_opts="$(grep " /cache " /proc/mounts | awk '{ print $4 }')"
 if [ -n "$mount_opts" ]; then
  local RW=""
  echo "$mount_opts" | grep -q ".*rw.*" && RW="true"
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
   mount $2 -t cifs -o username=linbo,password="$PASSWD",nolock "$1" /cache 2>> /tmp/linbo.log
   RC="$?"
   if [ "$RC" != "0" ]; then
    echo "Zugriff auf $1 als Benutzer \"linbo\" mit Authentifizierung klappt nicht."
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
     echo "Mounte Cache-Partition $1 ..."
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
   echo "Unbekannte Quelle fuer LINBO-Cache: $1" >&2
   ;;
  esac
 [ "$RC" = "0" ] || echo "Kann $1 nicht als /cache einbinden." >&2
 return "$RC"
}

killalltorrents(){
 local WAIT=5
 # check for running torrents and kill them if any
 if [ -n "`ps w | grep ctorrent | grep -v grep`" ]; then
  echo "Stoppe Torrents ..."
  killall -9 ctorrent 2>/dev/null
  sleep "$WAIT"
  [ -n "`ps w | grep ctorrent | grep -v grep`" ] && sleep "$WAIT"
 fi
}

# convert all units to MiB and ensure partability by 2048
convert_size(){
 local unit="$(echo $1 | sed 's|[^a-zA-Z]*||g')"
 local size="$(echo ${1/$unit} | awk -F\[,.] '{ print $1 }')"
 local unit="$(echo $unit | tr A-Z a-z | head -c1)"
 case "$unit" in
  k) size=$(( $size / 2048 * 2 )) ;;
  m) size=$(( $size / 2 * 2 )) ;;
  g) size=$(( $size * 1024 )) ;;
  t) size=$(( $size * 1024 * 1024 )) ;;
  *) return 1 ;;
 esac
 echo $size
}

# partition with parted, invoked by partition() for each disk
# args: table
mk_parted(){
 local table="$1"
 [ -s "$table" ] || return 1
 local disk="/dev/$(basename "$table")"
 [ -b "$disk" ] || return 1
 local lastnr="$(grep -c ^"$disk" "$table")"
 local dev
 local label
 local start
 local partstart
 local end
 local partend
 local extend
 local extpartend
 local size
 local unit="MiB"
 local id
 local fstype
 local partname
 local partflag
 local disklabel="msdos"
 local parttype="primary"
 local bootable
 local RC=0
 local CMD="parted -s -a opt $disk mkpart"
 # efi system -> gpt label
 systemtype | grep -qi efi && disklabel="gpt"
 echo "Erstelle neue $disklabel Partitionstabelle auf $disk."
 parted -s "$disk" mklabel "$disklabel" || RC="1"

 local n=0
 echo "partition label size id fstype bootable"
 while read dev label size id fstype bootable; do
  n=$(( n + 1 ))
  echo "$n: $dev $label $size $id $fstype $bootable"
  [ "$fstype" = "-" ] && fstype=""
  [ "$label" = "-" ] && label=""
  partname="" ; partflag=""

  # begin of first partition
  if [ $n -eq 1 ]; then
   start=1
  else
   if [ "$parttype" = "extended" -o "$parttype" = "logical" ]; then
    parttype="logical"
    # add 1 MiB to logical partition start position
    start=$(( $end + 1 ))
   else
    # start of next partition is the end of the partition before
    start=$end
   fi
  fi
  partstart=$start$unit

  # handle size if not set
  if [ "$size" = "-" ]; then
   partend="100%"
   extpartend="$partend"
  else
   isinteger "$size" && size="$size"k
   size="$(convert_size $size)"
   # don't increase the end counter in case of extended partition
   case "$id" in                                                                                                                
    5|05) extend=$(( $start + $size )) ; extpartend=$extend$unit ;;
    * ) end=$(( $start + $size )) ; partend=$end$unit ;;
   esac
  fi
  
  # handle partition name
  if [ -n "$label" -a "$disklabel" = "gpt" ]; then
   partname="$label"
  else
   partname="$parttype"
  fi

  # handle last logical partition if size was not set and size for extended was set
  [ "$n" = "$lastnr" -a "$parttype" = "logical" -a "$partend" = "100%" -a -n "$extend" ] && partend=$extend$unit

  # create partitions
  case "$id" in                                                                                                                
   c01|0c01) $CMD '"Microsoft reserved partition"' $partstart $partend || RC=1 ; partflag="msftres" ;;
   5|05)
    parttype="extended"
    $CMD $parttype $partstart $extpartend || RC=1
    if [ "$RC" = "0" ]; then
     # correct parted's idea of the extended partition id
     echo -e "t\n$n\n5\nw\n" | fdisk "$disk" 2>> /tmp/linbo.log 1>> /tmp/linbo.log || RC=1
    fi
    ;;
   6|06|e|0e) $CMD $partname fat16 $partstart $partend || RC=1 ;;
   7|07)
    if [ "$disklabel" = "gpt" ]; then
     $CMD '"Basic data partition"' NTFS $partstart $partend || RC=1
     partflag="msftdata"
    else
     $CMD $partname NTFS $partstart $partend || RC=1
    fi
    ;;
   b|0b|c|0c) $CMD $partname fat32 $partstart $partend || RC=1 ;;
   ef)
    if [ "$disklabel" = "gpt" ]; then
     $CMD '"EFI system partition"' fat32 $partstart $partend || RC=1
     partflag="boot"
    else
     $CMD $partname fat32 $partstart $partend || RC=1
     if [ "$RC" = "0" ]; then
      # correct parted's idea of the efi partition id on msdos disklabel
      echo -e "t\n$n\nef\nw\n" | fdisk "$disk" 2>> /tmp/linbo.log 1>> /tmp/linbo.log || RC=1
     fi
    fi
    ;;
   82) $CMD $partname linux-swap $partstart $partend || RC=1 ;;
   83) $CMD $partname $fstype $partstart $partend || RC=1 ;;
   *) $CMD $partname $partstart $partend || RC=1 ;;
  esac

  # set bootable flag
  if [ "$bootable" = "yes" ]; then
   if [ "$disklabel" = "msdos" ]; then
    echo -e "a\n$n\nw\n" | fdisk "$disk" 2>> /tmp/linbo.log 1>> /tmp/linbo.log || RC=1
   else
    # note: with gpt disklabel only one partition can own the bootable 
    # flag, so the last one wins if multiple boot flags were set
    parted -s "$disk" set $n boot on || RC="1"
   fi
  fi

  # set other flags                                                                                                            
  if [ -n "$partflag" ]; then                                                                                                  
   parted -s "$disk" set $n $partflag on || RC="1"
  fi

  # format partition if NOFORMAT is not set
  if [ -z "$NOFORMAT" -a -n "$fstype" ]; then
   format "$dev" "$fstype" "$label" || RC="1"
  fi

 done < "$table"
 
 if [ "$RC" = "0" ]; then
  echo "Partitionierung von $disk erfolgreich beendet!"
 else
  echo "Partitionierung von $disk fehlerhaft! Details siehe $(hostname)_linbo.log."
 fi
 return "$RC"
}

# Changed: All partitions start on cylinder boundaries.
# partition dev1 size1 id1 bootable1 filesystem dev2 ...
# When "$NOFORMAT" is set, format is skipped, otherwise all
# partitions with known fstypes are formatted.
partition(){
 killalltorrents
 #echo -n "partition " ;  printargs "$@"
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

 # collect partition infos from start.conf and write them to table
 local dev
 local label
 local size
 local id
 local fstype
 local bootable
 local line
 local table="/tmp/partitions"
 local RC="0"
 rm -f "$table"
 grep -v '^$\|^\s*\#' /start.conf | awk -F\# '{ print $1 }' | sed -e 's| ||g' -e 's|[ \t]||' | tr A-Z a-z | while read line; do
  if echo "$line" | grep -q ^'\['; then
   if [ -n "$dev" ]; then
    [ -z "$label" ] && label="-"
    [ -z "$fstype" ] && fstype="-"
    [ -z "$size" ] && size="-"
    [ -z "$bootable" ] && bootable="-"
    echo "$dev $label $size $id $fstype $bootable" >> "$table"
   fi
   dev=""; label=""; id=""; fstype=""; size=""; bootable=""
   continue
  fi
  case "$line" in dev=*|label=*|id=*|fstype=*|size=*|bootable=*) eval "$line" ;; esac
 done

 # get all disks from start.conf
 local disks="$(get_disks)"
 local disk
 local diskname
 # sort table by disks and partitions
 for disk in $disks; do
  diskname="${disk#\/dev\/}"
  grep ^"$disk" "$table" | sort > "/tmp/$diskname"
  mk_parted "/tmp/$diskname" || RC="1"
 done
 rm -f /tmp/.update.done
 rm -f /tmp/.grub-install
 rm -f /tmp/.prepare_grub
 return "$RC"
}

# print efi partition
print_efipart(){
 # test for efi system
 [ -d /sys/firmware/efi ] || return 1
 local dev
 local id
 local label
 local line
 grep -v '^$\|^\s*\#' /start.conf | awk -F\# '{ print $1 }' | sed -e 's| ||g' -e 's|[ \t]||' | tr A-Z a-z | while read line; do
  if echo "$line" | grep -q ^'\['; then
   if [ "$id" = "ef" ]; then
    echo "$dev"
    return 0
   fi
   dev=""; id=""; label=""
   continue
  fi
  case "$line" in dev=*|id=*|label=*) eval "$line" ;; esac
 done
}

# print_grubpart partition
print_grubpart(){
 local partition="$1"
 [ -b "$partition" ] || return 1
 local partnr="$(echo "$partition" | sed -e 's|/dev/[hsv]d[abcdefgh]||' -e 's|/dev/xvd[abcdefgh]||' -e 's|/dev/mmcblk[0-9]p||')"
 case "$partition" in
  /dev/mmcblk*) local disknr="$(echo "$partition" | sed 's|/dev/mmcblk\([0-9]*\)p[0-9]*|\1|')" ;;
  *)
   local ord="$(printf "$(echo $partition | sed 's|/dev/*[hsv]d\([a-z]\)[0-9]|\1|')" | od -A n -t d1)"
   local disknr=$(( $ord - 97 ))
   ;;
 esac
 echo "(hd${disknr},${partnr})"
}

# print efi bootnr of given item
# print_efi_bootnr item efiout
print_efi_bootnr(){
 local item="$1"
 local efiout="$2"
 [ -z "$item" ] && return 1
 if [ -s "$efiout" ]; then
  local bootnr="$(grep -iw "$item" "$efiout" | head -1 | awk -F\* '{ print $1 }' | sed 's|^Boot||')"
 else
  local bootnr="$(efibootmgr | grep -iw "$item" | head -1 | awk -F\* '{ print $1 }' | sed 's|^Boot||')"
 fi
 if [ -n "$bootnr" ]; then
  echo "$bootnr"
 else
  return 1
 fi
}

# create efi boot entry
# create_efiboot label efipart
create_efiboot(){
 # return if entry exists
 efibootmgr | grep ^Boot[0-9] | awk -F\* '{ print $2 }' | grep -qiw " $1" && return 0
 local label="$1"
 local efipart="$2"
 local efidisk="$(get_disk_from_partition "$efipart")"
 local efipartnr="$(echo "$efipart" | sed "s|$efidisk||")"
 local efiloader
 local bits
 case "$label" in
  *[Ww][Ii][Nn][Dd][Oo][Ww][Ss]*) efiloader="\\EFI\\Microsoft\\Boot\\bootmgfw.efi" ;;
  grub)
   bits="$(get_64)"
   [ -z "$bits" ] && bits="32"
   efiloader="\\EFI\\grub\\grubx${bits}.efi"
   ;;
  *) return 1 ;;
 esac
 efibootmgr --create --disk "$efidisk" --part "$efipartnr" --loader "$efiloader" --label "$label" 2>> /tmp/linbo.log 1>> /tmp/linbo.log || return 1
}

# set_efibootnext: creates efi bootnext entry
# args: bootloaderid
set_efibootnext(){
 local bootloaderid="$1"
 # get the bootnr
 local bootnextnr="$(print_efi_bootnr "$bootloaderid")"
 if [ -n "$bootnextnr" ]; then
  efibootmgr --bootnext "$bootnextnr" 2>> /tmp/linbo.log 1>> /tmp/linbo.log || return 1
 else
  return 1
 fi
}

# set_efibootorder: set the boot order to local,network
set_efibootorder(){
 local efiout="/tmp/efiout"
 efibootmgr | grep ^Boot[0-9] > "$efiout"
 local grubnumber="$(print_efi_bootnr " grub" "$efiout")"
 local netnumbers="$(print_efi_bootnr " ipv4 " "$efiout")"
 netnumbers="$netnumbers $(print_efi_bootnr "efi network" "$efiout")"
 local bootorder
 if [ -n "$grubnumber" -o -n "$netnumbers" ]; then
  for i in $grubnumber $netnumbers; do
   if [ -n "$bootorder" ]; then
    bootorder="$bootorder,$i"
   else
    bootorder="$i"
   fi
  done
  echo "Setze EFI Bootreihenfolge auf Lokal,Netzwerk: $bootorder."
  efibootmgr --bootorder "$bootorder" 2>> /tmp/linbo.log 1>> /tmp/linbo.log || return 1
 fi
}

# repair_efi: sets efi configuration into a proper state
# args: efipart
repair_efi(){
 local doneflag="/tmp/.repair_efi"
 [ -e "$doneflag" ] && return 0
 local efipart="$1"
 local efiout="/tmp/efiout"
 local startflag="/tmp/.start"
 local line
 local item
 local FOUND
 local bootnr
 # first remove redundant entries, keep entries with higher number
 efibootmgr | grep ^Boot[0-9] | sort -r > "$efiout" || return 1
 # read in the unique boot entries and test for multiple occurances of the same item
 awk -F\* '{ print $2 }' "$efiout" | sort -u | while read item; do
  [ -z "$item" ] && continue
  line=""
  FOUND=""
  # delete redundant entries
  grep "$item" "$efiout" | while read line; do
   if [ -z "$FOUND" ]; then
    FOUND="yes"
    continue
   else
    bootnr="$(echo "$line" | awk -F\* '{ print $1 }' | sed 's|Boot||')"
    efibootmgr --bootnum "$bootnr" --delete-bootnum 2>> /tmp/linbo.log 1>> /tmp/linbo.log || return 1
   fi
  done
 done
 # create grub entry if missing
 create_efiboot grub "$efipart" || return 1
 # set bootorder
 if [ ! -e "$startflag" ]; then
  set_efibootorder || return 1
 fi
 touch "$doneflag"
}

# write_devicemap devicemap
# write grub device.map file
write_devicemap() {
 [ -z "$1" ] && return 1
 local devicemap="$1"
 local disk
 local n=0
 rm -f "$devicemap"
 for disk in $(get_disks); do
  echo "(hd${n}) $disk" >> "$devicemap"
  n=$(( $n + 1 ))
 done
 [ -s "$devicemap" ] || return 1
}

# umount_boot
# unmounts boot partition
umount_boot(){
 local i
 for i in /boot/efi /boot; do
  if mount | grep -q " $i "; then
   umount "$i" || umount -l "$i"
  fi
 done
}

# mount_boot efipart
# fake mounts boot partition for grub
mount_boot(){
 local efipart="$1"
 mkdir -p /boot
 if ! mount | grep -q " /boot "; then
  mount --bind /cache/boot /boot || return 1
 fi
 if [ -n "$efipart" ]; then
  if ! mount | grep -q " /boot/efi "; then
   mkdir -p /boot/efi
   if ! mount "$efipart" /boot/efi; then
    umount_boot
    return 1
   fi
  fi
 fi
}

# mk_winefiboot: restore and install windows efi boot files
# args: partition efipart bootloaderid 
mk_winefiboot(){
 local partition="$1"
 local doneflag="/tmp/.mk_winefiboot.$(basename "$partition")"
 [ -e "$doneflag" ] && return 0
 local efipart="$2"
 local bootloaderid="$3"
 local RC="0"
 local win_bootdir="$(ls -d /mnt/[Ee][Ff][Ii]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]/[Bb][Oo][Oo][Tt] 2> /dev/null)"
 # restore bcd from old bios boot dir
 if [ -n "$win_bootdir" ]; then
  # restore bcd and efiboot files on efi partition
  local win_bcd="$(ls "$win_bootdir"/[Bb][Cc][Dd] 2> /dev/null)"
  if [ -n "$win_bcd" ]; then
   local win_efidir="$(ls -d /boot/efi/[Ee][Ff][Ii]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]/[Bb][Oo][Oo][Tt] 2> /dev/null)"
   if [ -z "$win_efidir" ]; then
    win_efidir="/boot/efi/EFI/Microsoft/Boot"
    mkdir -p "$win_efidir"
   fi
   # copy whole windows efi stuff to efi partition
   echo "Stelle Windows-Bootdateien auf EFI-Partition wieder her."
   rsync -r "$win_bootdir/" "$win_efidir/"
  fi
 else
  echo "Kann Windows-EFI-Bootdateien nicht restaurieren."
  RC="1"
 fi
 # create efi bootloader entry if missing
 create_efiboot "$bootloaderid" "$efipart" || RC="1"
 [ "$RC" = "0" ] && touch "$doneflag"
 return "$RC"
}

# mk_linefiboot: prepares linux os for efi boot
# args: partition grubdisk efipart bootloaderid
mk_linefiboot(){
 [ -d /mnt/boot/grub ] || return 1
 local partition="$1"
 local doneflag="/tmp/.mk_linefiboot.$(basename "$partition")"
 [ -e "$doneflag" ] && return 0
 local grubdisk="$2"
 local efipart="$3"
 local bootloaderid="$4"
 local RC="0"
 mkdir -p /mnt/boot/efi
 mount "$efipart" /mnt/boot/efi || return 1
 mkdir -p /mnt/boot/efi/EFI
 grub-install --root-directory=/mnt --bootloader-id="$bootloaderid" "$grubdisk" 2>> /tmp/linbo.log || RC="1"
 umount /mnt/boot/efi
 [ "$RC" = "0" ] || touch "$doneflag"
 return "$RC"
}

# mk_efiboot: if returns 1 a reboot via grub will be initiated, othwerwise reboot via efi directly
# args: efipart partition grubdisk
mk_efiboot(){
 local efipart="$1"
 local partition="$2"
 local grubdisk="$3"
 local startflag="/tmp/.start"
 local bootloaderid
 local doneflag="/tmp/.grub-install"
 # repare efi configuration
 repair_efi "$efipart" || return 1
 # restore windows efi boot files
 local RC="0"
 if [ "$(fstype $partition)" = "ntfs" ]; then
  bootloaderid="Windows Boot Manager"
  mk_winefiboot "$partition" "$efipart" "$bootloaderid" || RC="1"
 else # assume linux system
  bootloaderid="$(osname "$partition")"
  if [ -n "$bootloaderid" ]; then
   mk_linefiboot "$partition" "$grubdisk" "$efipart" "$bootloaderid" || RC="1"
  fi
 fi
 # install default efi boot file
 local grubefi="/boot/efi/EFI/grub/grubx64.efi"
 if [ -s "$grubefi" ]; then
  echo "Stelle EFI-Standardboot wieder her."
  local efibootdir="$(ls -d /boot/efi/EFI/B[Oo][Oo][Tt] 2>/dev/null)"
  [ -z "$efibootdir" ] && efibootdir="/boot/efi/EFI/BOOT"
  local bootefi="$(ls $efibootdir/[Bb][Oo][Oo][Tt][Xx]64.[Ee][Ff][Ii] 2>/dev/null)"
  [ -z "$bootefi" ] && bootefi="$efibootdir/BOOTX64.EFI"
  mkdir -p "$efibootdir"
  rsync "$grubefi" "$bootefi" || RC="1"
 fi
 # set efi bootnext entry if invoked by start()
 if [ -e "$startflag" -a -n "$bootloaderid" ]; then
  set_efibootnext "$bootloaderid" || RC="1"
  # set bootorder
  set_efibootorder || RC="1"
  # cause another grub-install
  [ "$RC" = "0" ] && rm -f "$doneflag"
 fi
 [ "$RC" = "1" ] && echo "Fehler beim Schreiben der EFI-Boot-Konfiguration."
 return "$RC"
}

# mk_grubboot partition grubenv kernel initrd append
# prepare for grub boot after reboot
mk_grubboot(){
 local partition="$1"
 local grubenv="$2"
 local KERNEL="$3"
 [ -z "$KERNEL" ] && return 0
 local doneflag="/tmp/.mk_grubboot.$(basename "$partition")"
 [ -e "$doneflag" ] && return 0
 local INITRD="$4"
 local APPEND="$5"
 local RC="0"
 # reboot partition is the partition where the os is installed
 local REBOOT="$(print_grubpart $partition)"
 # save reboot informations in grubenv
 echo "Schreibe Reboot-Informationen nach $grubenv."
 grub-editenv "$grubenv" set reboot_grub="$REBOOT" || RC="1"
 if [ "$KERNEL" != "[Aa][Uu][Tt][Oo]" ]; then
  [ "${KERNEL:0:1}" = "/" ] || KERNEL="/$KERNEL"
  grub-editenv "$grubenv" set reboot_kernel="$KERNEL" || RC="1"
  if [ -n "$INITRD" ]; then
   [ "${INITRD:0:1}" = "/" ] || INITRD="/$INITRD"
   grub-editenv "$grubenv" set reboot_initrd="$INITRD" || RC="1"
  fi
  if [ -n "$APPEND" ]; then
   grub-editenv "$grubenv" set reboot_append="$APPEND" || RC="1"
  fi
 fi
 [ "$RC" = "0" ] && touch "$doneflag"
 return "$RC"
}

# prepare_reboot: prepares filesystem for reboot to os
# args: grubdisk partition grubenv kernel initrd append efipart  
prepare_reboot(){
 local grubdisk="$1"
 local partition="$2"
 local grubenv="$3"
 local KERNEL="${4#/}"
 local INITRD="${5#/}"
 local APPEND="$6"
 local efipart="$7"
 local efiboot="false"
 local noefibootmgr="$(kerneloptions | grep -iw noefibootmgr)"
 remote_cache "$(cachedev)" || local localcache="yes"
 if [ -z "$noefibootmgr" -a -n "$efipart" ]; then
  mk_efiboot "$efipart" "$partition" "$grubdisk" && efiboot="true"
 fi
 if [ "$efiboot" = "false" ]; then
  if [ -n "$localcache" ]; then
   mk_grubboot "$partition" "$grubenv" "$KERNEL" "$INITRD" "$APPEND" || return 1
  else
   # create reboot grubenv file on server
   local rebootstr="$(print_grubpart $partition)#${KERNEL}#${INITRD}#${APPEND}#.reboot"
   rsync $(serverip)::linbo/"$rebootstr" /tmp 2>"$TMP" || true
  fi
 fi
}

# prepare_grub: install and reset grub files in cache
# args: grubdir grubenv grubsharedir
prepare_grub(){
 local doneflag="/tmp/.prepare_grub"
 [ -e "$doneflag" ] && return 0
 echo "Aktualisiere GRUB-Dateien im Cache:"
 local grubdir="$1"
 local grubenv="$2"
 local grubsharedir="$3"
 [ -e "$grubdir" ] || mkdir -p "$grubdir"
 # write grub device.map file
 echo -n " * Schreibe device.map ... "
 write_devicemap "$grubdir/device.map" || return 1
 echo "Ok!"
 # provide default grub.cfg with current append params on localmode
 if localmode; then
  echo -n " * Schreibe GRUB-Konfiguration in localmode ... "
  local kopts="$(kerneloptions)"
  [ -z "$kopts" ] && kopts="splash quiet localboot"
  sed -e "s|linux \$linbo_kernel .*|linux \$linbo_kernel $(kerneloptions) localboot|g" "$grubsharedir/grub.cfg" > "$grubdir/grub.cfg"
  echo "Ok!"
 fi
 # provide unicode font
 echo -n " * Stelle unicode.pf2 bereit ... "
 rsync "$grubsharedir/unicode.pf2" "$grubdir/unicode.pf2" || return 1
 echo "Ok!"
 # provide menu background image
 echo -n " * Stelle Hintergrundgrafik bereit ... "
 rsync /icons/linbo_wallpaper.png "$grubdir/linbo_wallpaper.png" || return 1
 echo "Ok!"
 # reset grubenv
 echo -n " * Schreibe GRUB-Environment ... "
 local RC="0"
 if [ -s "$grubenv" ]; then
  for i in reboot reboot_kernel reboot_initrd reboot_append; do
   grub-editenv "$grubenv" unset "$i" || RC="1"
  done
 else
  grub-editenv "$grubenv" create || RC="1"
 fi
 echo "Ok!"
 [ "$RC" = "0" ] && touch "$doneflag"
 return "$RC"
}

# mk_boot: configure boot stuff
# args: partition kernel initrd append
mk_boot(){
 local KERNEL="${2#/}"
 local INITRD="${3#/}"
 local APPEND="$4"
 local efipart="$(print_efipart)"
 local partition="$1"
 remote_cache "$(cachedev)" || local localcache="yes"
 # get disk for grub install, use always the first disk
 local grubdisk="$(get_disks | head -1)"
 if [ ! -b "$grubdisk" ]; then
  echo "$grubdisk ist kein Blockdevice!"
  return 1
 fi
 # mount boot partitions
 mount_boot "$efipart" || return 1
 # needed grub dirs
 local grubdir="/cache/boot/grub"
 local grubenv="$grubdir/grubenv"
 local grubsharedir="/usr/share/grub"
 local doneflag="/tmp/.grub-install"
 local RC="0"
 # prepare grub stuff
 if [ -n "$localcache" ]; then
  prepare_grub "$grubdir" "$grubenv" "$grubsharedir" || RC="1"
 fi
 # prepare reboot stuff
 if [ -n "$partition" ]; then
  prepare_reboot "$grubdisk" "$partition" "$grubenv" "$KERNEL" "$INITRD" "$APPEND" "$efipart" || RC="1"
 fi
 # install grub in mbr/efi
 if [ ! -e "$doneflag" -a -n "$localcache" ]; then
  echo -n "Installiere GRUB in MBR/EFI von $grubdisk ... "
  grub-install "$grubdisk" 2>> /tmp/linbo.log || RC="1"
  if [ "$RC" = "0" ]; then
   touch "$doneflag"
   echo "OK!"
  else
   echo "Fehler!"
  fi
 fi
 # umount boot partitions if mounted
 umount_boot
 return "$RC"
}

# download server file [important]
download(){
 local RC=1
 [ -n "$3" ] && echo "RSYNC Download $1 -> $2..."
 rm -f "$TMP"
 interruptible rsync -HaLz --partial "$1::linbo/$2" "$(basename $2)" 2>"$TMP"; RC="$?"
 if [ "$RC" != "0" ]; then
  # Delete incomplete/defective/non-existent file (maybe we should check for returncode=23 first?)
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
 remote_cache "$(cachedev)" || rm -f "/cache/$macctfile"
}

# do_machinepw (not used)
# no args
# handle machine password stuff locally and on the server
do_machinepw(){
 local mpwfile="$(uuidgen).mpw"
 download "$(serverip)" "$mpwfile"
 local RC="0"
 if [ -s "$mpwfile" ]; then
  local machinepw="$(cat $mpwfile)"
  local srcdir="/linuxmuster-win"
  local tgtdir="/mnt$srcdir"
  sed -e "s|@@machinepw@@|$machinepw|" "$srcdir/set_machinepw.cmd.tpl" > "$tgtdir/set_machinepw.cmd" || RC="1"
  if [ "$RC" = "0" ]; then
   cp "$srcdir/lsaSecretStore.exe" "$tgtdir" || RC="1"
  fi
  [ "$RC" = "0" ] && echo "Maschinenpasswort wurde gesetzt."
 else
  RC="1"
 fi
 rm -f "$mpwfile"
 return "$RC"
}

# update linuxmuster-win scripts and install start tasks
# no args
# invoked by start() & syncl()
update_win(){
 local doneflag="/tmp/.update_win"
 [ -e "$doneflag" ] && return 0
 local RC="0"
 mkdir -p /mnt/linuxmuster-win
 # copy scripts to os rootdir
 rsync -r --delete /cache/linuxmuster-win/ /mnt/linuxmuster-win/ || RC="1"
 # install start tasks
 if [ "$RC" = "0" ]; then
  /linuxmuster-win/install-start-tasks.sh || RC="1"
 fi
 [ "$RC" = "0" ] && touch "$doneflag"
 return "$RC"
}

# start: start operating system
# args: boot root kernel initrd append cache
start(){
 echo -n "start " ;  printargs "$@"
 # if no kernel is given, do not start
 if [ -z "$3" ]; then
  echo "Nichts zu starten!"
  return 0
 fi
 local INITRD
 local APPEND
 local KERNEL="${3#/}"
 local i
 local partition="$2"
 local cachedev="$6"
 local startflag="/tmp/.start"
 touch "$startflag"
 if mountpart "$partition" /mnt -w 2>> /tmp/linbo.log; then
  if [ -e "/mnt/$KERNEL" ]; then
   echo "Kernel $KERNEL auf Partition $partition gefunden."
   INITRD="${4#/}"
   APPEND="$5"
   [ -n "$partition" ] && APPEND="root=$partition $APPEND"
  else
   echo "Kernel $KERNEL auf Partition $partition nicht vorhanden. Setze auf \"auto\"."
   KERNEL="auto"
  fi
  if mountcache "$cachedev"; then
   # install/update grub/efi stuff if cache is mounted
   mk_boot "$partition" "$KERNEL" "$INITRD" "$APPEND" | tee -a /tmp/linbo.log
   # update linuxmuster-win scripts and install start tasks
   [ "$(fstype "$partition")" = "ntfs" -a -d /cache/linuxmuster-win ] && update_win | tee -a /tmp/linbo.log
  fi
 else
  echo "Konnte Betriebssystem-Partition $partition nicht mounten." >&2
  umount /mnt 2>> /tmp/linbo.log
  mountcache "$cachedev" -r
  return 1
 fi
 # sets machine password on server
 invoke_macct
 # kill torrents if any
 killalltorrents
 sync
 umount /mnt 2>> /tmp/linbo.log
 sendlog
 # reboot to operating system
 reboot -f
}

# return partition size in kilobytes
# arg: partition
get_partition_size(){
 local part="$1"
 local disk="$(get_disk_from_partition "${part}")"
 if echo "${part}" | grep -q '^/dev/mmcblk'; then
  local partnr="$(echo "${part}" | sed -e 's|/dev/mmcblk[0-9]p||')"
 else
  local partnr="$(echo "${part}" | sed -e 's|/dev/[hsv]d[abcdefgh]||')"
 fi
 # fix vanished cloop symlink
 if [ "$1" = "/dev/cloop" ]; then
  [ -e "/dev/cloop" ] || ln -sf /dev/cloop0 /dev/cloop
 fi
 if  [ "$disk" = "$part" ]; then
  parted -sm "$disk" unit kiB print | grep ^${disk}: | awk -F\: '{ print $2 }' | sed 's|kiB||' 2>> /tmp/linbo.log
 else
  parted -sm "$disk" unit kiB print | grep ^${partnr}: | awk -F\: '{ print $4 }' | sed 's|kiB||' 2>> /tmp/linbo.log
 fi
 #sfdisk -s "$1" 2>> /tmp/linbo.log
 return $?
}

# echo file size in bytes
get_filesize(){
 ls -l "$1" 2>/dev/null | awk '{print $5}' 2>/dev/null
 return $?
}

# mk_exclude
# Create /tmp/rsync.exclude
mk_exclude(){
rm -f /tmp/rsync.exclude
cat > /tmp/rsync.exclude <<EOT
${RSYNC_EXCLUDE}
EOT
}

# save_efi_bcd targetdir efipart
# saves the windows efi file to os partition
save_efi_bcd(){
 local targetdir="$1"
 local efipart="$2"
 local efimnt="/cache/boot/efi"
 mkdir -p "$efimnt"
 mount "$efipart" "$efimnt" || return 1
 local sourcedir="$(ls -d "$efimnt"/[Ee][Ff][Ii]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]/[Bb][Oo][Oo][Tt] 2> /dev/null)"
 if [ -z "$sourcedir" ]; then
  echo "$sourcedir nicht vorhanden. Kann Windows-EFI-Bootdateien nicht nach $targetdir kopieren."
  umount "$efimnt" || umount -l "$efimnt"
  return 1
 fi
 echo "Kopiere Windows-EFI-Bootdateien von $sourcedir nach $targetdir."
 mkdir -p "$targetdir"
 local RC=0
 rsync -r "$sourcedir/" "$targetdir/" || RC="1"
 umount "$efimnt" || umount -l "$efimnt"
 [ "$RC" = "1" ] && echo "Fehler beim Kopieren der Windows-EFI-Bootdateien."
 return "$RC"
}

# print_guid partition
# print gpt uuid of a partition (works only with efi)
print_guid(){
 local partition="$1"
 local disk="$(get_disk_from_partition "${partition}")"
 local partnr="$(echo "$partition" | sed "s|$disk||")"
 echo -e "i\n$partnr\nq\n" | gdisk "$disk" | grep -i "partition unique guid" | awk -F\: '{ print $2 }' | awk '{ print $1 }' 2> /dev/null
}

# set_guid partition guid flag
# sets gpt uuid of a partition (works only with efi)
set_guid(){
 local partition="$1"
 local guid="$2"
 [ -z "$partition" -a -z "$guid" ] && return 1
 echo "Restauriere Partitions-GUID von $partition."
 local disk="$(get_disk_from_partition "${partition}")"
 local partnr="$(echo "$partition" | sed "s|$disk||")"
 echo -e "x\nc\n$partnr\n$guid\nw\nY\n" | gdisk "$disk" &> /tmp/image.log || return 1
}

# prepare_fs directory partition
# Removes all files from ${RSYNC_EXCLUDE} and saves win7 boot configuration in
# the root directory of the os.
prepare_fs(){
 (
  # remove excluded files
  cd "$1" || return 1
  local i=""
  for i in ${RSYNC_EXCLUDE}; do # Expand patterns
   if [ -e "$i" ]; then
    echo "Entferne $i."
    rm -rf "$i"
   fi
  done
  # save win7 bcd & mbr
  local targetdir
  # in case of efi save the windows efi files
  local efipart="$(print_efipart)"
  if [ -n "$efipart" ]; then
   # save partition uuids
   echo "Sichere Partitions-GUIDs."
   print_guid "$efipart" > /mnt/.guid.efi
   print_guid "$2" > /mnt/.guid."$(basename "$2")"
   if [ "$(fstype $2)" = "ntfs" ]; then
    targetdir="$(ls -d [Ee][Ff][Ii]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][Ff][Tt]/[[Bb][Oo][Oo][Tt] 2> /dev/null)"
    [ -z "$targetdir" ] && targetdir="EFI/Microsoft/Boot"
    save_efi_bcd "$targetdir" "$efipart" | tee -a /tmp/linbo_image.log
   fi
  else
   targetdir="$(ls -d [Bb][Oo][Oo][Tt] 2> /dev/null)"
  fi
  if [ -n "$targetdir" ]; then
   local bcd="$(ls $targetdir/[Bb][Cc][Dd] 2> /dev/null)"
   local group="$(hostgroup)"
   if [ -n "$bcd" -a -n "$group" ]; then
    echo "Sichere Windows-Bootloader fuer Gruppe $group."
    # BCD group specific and partition specific on efi systems
    if [ -n "$efipart" ]; then
     cp -f "$bcd" "$bcd"."$group"."$(basename "$2")"
    else
     cp -f "$bcd" "$bcd"."$group"
    fi
    # boot sector backup group specific
    echo "Sichere Disk-Bootsektoren fuer Gruppe $group."
    # delete obsolete mbr backups
    rm -f "$targetdir/winmbr.$group" "$targetdir/win7mbr.$group" "$targetdir/winmbr446.$group"
    local disk="$(get_disk_from_partition "$2")"
    local bsmbr="$targetdir/bsmbr.$group"
    dd if="$disk" of="$bsmbr" bs=446 count=1 2>> /tmp/linbo.log
    local bsvbr="$targetdir/bsvbr.$group"
    dd if="$disk" of="$bsvbr" bs=446 count=63 2>> /tmp/linbo.log
    # ntfs partition id
    echo "Sichere NTFS-ID."
    local ntfsid="$targetdir/ntfs.id"
    dd if="$2" of="$ntfsid" bs=8 count=1 skip=9 2>> /tmp/linbo.log
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
    echo "Bereite Partition $2 (Groesse=${size}K) fuer Komprimierung vor..." | tee -a /tmp/image.log
    prepare_fs /mnt "$2" | tee -a /tmp/image.log
    echo "Leeren Platz auffuellen mit 0en..." | tee -a /tmp/image.log
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
      mk_exclude
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
     echo "ist aber fuer die differentielle Sicherung notwendig." | tee -a /tmp/image.log
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
  echo "Erstelle Torrent-Dateien ..." | tee -a /tmp/image.log
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
# [ "$RC" = "0" ] && echo "Enthaelt schon eine Version von $2."
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
 interruptible ntfsclone -q -f --overwrite "$targetdev" /dev/cloop 2>> /tmp/image.log ; RC="$?"
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
    echo "FEHLER: CLOOP-Image $imagefile (${s1}K) ist groesser als Partition $targetdev (${s2}K)" >&2 | tee -a /tmp/image.log
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
      mk_exclude
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
  # ntfsfix after sync
  #[ "$fstype" = "ntfs" ] && ntfsfix -d "$2"
  echo "Fertig."
 else
  echo "Fehler!" >&2
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
 local key
 local RC="0"
 if [ -n "$2" ]; then
  image="$2"
 else
  image="$1"
 fi
 # request opsikey
 localmode || rsync "$serverip"::linbo/"$ip.opsikey" /tmp/opsikey
 if [ -s /tmp/opsikey ]; then
  key="$(cat /tmp/opsikey)"
  # save opsi host key for offline use
  remote_cache "$(cachedev)" || cp /tmp/opsikey /cache
 else
  # load opsi from cache
  [ -s /cache/opsikey ] && key="$(cat /cache/opsikey)"
 fi
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
  echo "Opsi-Host-Key ist nicht verfuegbar."
 fi
 rm -f /tmp/opsikey
 # request opsi host ini update
 localmode || rsync "$serverip"::linbo/"$image.opsi" /cache &> /dev/null || true
 return "$RC"
}

# restore windows activation tokens
restore_winact(){
 # get image name
 [ -s  /mnt/.linbo ] && local image="$(cat /mnt/.linbo)"
 # if an image is not yet created do nothing
 if [ -z "$image" ]; then
  echo "Ueberspringe Reaktivierung, System ist unsynchronisiert."
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
  # get server ip address
  local serverip="$(grep ^linbo_server /tmp/dhcp.log | tail -1 | awk -F\' '{ print $2 }')"
  echo -n "Fordere Reaktivierungs-Daten von $serverip an ... "
  # get token archive from linbo server
  rsync "$serverip"::linbo/winact/"$archive" /cache &> /dev/null
  if [ -s "/cache/$archive" ]; then
   echo "OK!"
  else
   echo "ueberspringe Reaktivierung, keine Daten!"
   return
  fi
  # request windows/office productkeys
  local keyfile="$(ifconfig -a | md5sum | awk '{ print $1 }').winkey"
  rsync "$serverip"::linbo/winact/"$keyfile" /cache &> /dev/null
  [ -s "/cache/$keyfile" ] && source "/cache/$keyfile"
  # create windows key batchfile
  if [ -n "$winkey" ]; then
   echo "cscript.exe %SystemRoot%\\System32\\slmgr.vbs -ipk $winkey" > "/cache/$image.winact.cmd"
  fi
  # add office key handling to batchfile if office token is in archive
  if gunzip -c "/cache/$archive" | tar -t | grep -qi office 2> /dev/null; then
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
  rm -f "$keyfile"
 fi
 # no data available
 if [ -s "/cache/$image.winact.cmd" ]; then
  dos2unix "/cache/$image.winact.cmd"
 else
  echo "Ueberspringe Reaktivierung, keine Produktkeys gefunden."
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
 local RC="1"
 local patchfile=""
 local postsync=""
 local rootdev="$5"
 local disk="${rootdev%%[1-9]*}"
 local group="$(hostgroup)"
 local bootdir

 # don't sync in that case
 if [ "$1" = "$rootdev" ]; then
  echo "Ueberspringe lokale Synchronisation. Image $2 wird direkt aus Cache gestartet."
  return 0
 fi

 # begin syncing
 echo -n "syncl " ; printargs "$@"

 # mount cache and sync
 mountcache "$1" || return "$?"
 cd /cache
 local image=""
 # start syncing images
 for image in "$2" "$3"; do
  [ -n "$image" -a -f "$image" ] || continue
  restore "$image" "$5" $9 ; RC="$?"
  [ "$RC" = "0" ] || break
  patchfile="$image.reg"
  postsync="$image.postsync"
 done

 # mount os partition
 if [ "$RC" = "0" ]; then
  mountpart "$5" /mnt -w 2>> /tmp/linbo.log ; RC="$?"
 fi
 # return on error
 if [ "$RC" != "0" ]; then
  echo "Kann $5 nicht einhaengen!" | tee -a /tmp/linbo.log
  sendlog
  cd /
  return "$RC"
 fi

 # detect windows os
 [ -e /mnt/[Nn][Tt][Ll][Dd][Rr] -o -e /mnt/[Bb][Oo][Oo][Tt][Mm][Gg][Rr] -o -d /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32 ] && local is_win="yes"

 # get hostname
 local HOSTNAME
 if localmode; then
  [ -s /cache/hostname ] && HOSTNAME="$(cat /cache/hostname)"
 fi
 [ -z "$HOSTNAME" ] && HOSTNAME="$(hostname)"

 # detect efi system if efi partition exists
 local efipart="$(print_efipart)"

 ## Prepare os filesystem, apply patches etc.

 # restore guids in case of efi/gpt partitions
 local sysname
 if [ -n "$efipart" ]; then
  sysname="EFI"
  # restore partition guids
  local partname="$(basename "$rootdev")"
  # get guids with old method
  [ -s /mnt/.guids ] && source /mnt/.guids
  if [ -s /mnt/.guid.efi ]; then
   set_guid "$efipart" "$(cat /mnt/.guid.efi)"
  else
   [ -n "$guid_efi" ]&& set_guid "$efipart" "$guid_efi"
  fi
  if [ -s "/mnt/.guid.$partname" ]; then
   set_guid "$rootdev" "$(cat /mnt/.guid."$partname")"
  else
   [ -n "$guid_os" ] && set_guid "$rootdev" "$guid_os"
  fi
 else
  sysname="BIOS"
 fi # efipart
 echo "$sysname-System gefunden."

 # windows stuff begin
 if [ -n "$is_win" ]; then

  # do registry patching for windows systems
  if [ -s "$patchfile" ]; then
   echo "Patche Windows-Registry mit $patchfile." | tee /tmp/patch.log
   sed 's|{\$HostName\$}|'"$HOSTNAME"'|g' "$patchfile" > "$TMP"
   dos2unix "$TMP"
   cat "$TMP" >>/tmp/patch.log
   patch_registry "$TMP" /mnt 2>&1 >>/tmp/patch.log
   [ -e /tmp/output ] && cat /tmp/output >>/tmp/patch.log
   rm -f "$TMP"
  fi # reg patch

  # tweak windows newdev.dll (suppresses new hardware dialog)
  local newdevdll="$(ls /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Nn][Ee][Ww][Dd][Ee][Vv].[Dd][Ll][Ll] 2> /dev/null)"
  [ -z "$newdevdll" ] && newdevdll="$(ls /mnt/[Ww][Ii][Nn][NN][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Nn][Ee][Ww][Dd][Ee][Vv].[Dd][Ll][Ll] 2> /dev/null)"
  local newdevdllbak="$newdevdll.linbo-orig"
  # save original file
  [ -n "$newdevdll" -a ! -e "$newdevdllbak" ] && cp "$newdevdll" "$newdevdllbak"
  # patch newdev.dll
  if [ -n "$newdevdll" ]; then
   echo -n "Patche $newdevdll ... "
   local bcmd
   local RC_BVI
   # read substitute commands line for line from file
   grep ^s/ /etc/newdev-patch.bvi | while read bcmd; do
    echo "$bcmd" >> /tmp/patch.log
    bvi -c "$bcmd" +"w" +"q" "$newdevdll" 2>&1 >> /tmp/patch.log || RC_BVI="1"
    [ "$RC_BVI" = "1" ] && break
   done
   if [ "$RC_BVI" = "1" ]; then
    echo "Fehler! Siehe patch.log."
    RC="$RC_BVI"
   else
    echo "OK!"
   fi
  fi

  # restore windows boot files
  local bcd_backup

  # get boot files
  # efi
  if [ -n "$efipart" ]; then
   # detect efi boot dir backup
   bootdir="$(ls -d /mnt/[Ee][Ff][Ii]/[Mm][Ii][Cc][Rr][Oo][Ss][Oo][ff][Tt]/[Bb][Oo][Oo][Tt] 2> /dev/null)"
   # create efi boot dir from bios boot stuff if not exists
   if [ -z "$bootdir" ]; then
    bootdir="/mnt/EFI/Microsoft/Boot"
    mkdir -p "$bootdir"
    local oldbootdir="$(ls -d /mnt/[Bb][Oo][Oo][Tt] 2> /dev/null)"
    if [ -n "$oldbootdir" ]; then
     cp -r "$oldbootdir"/* "$bootdir/"
    fi
    local srcdir="$(ls -d /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Bb][Oo][Oo][Tt]/[Ee][Ff][Ii] 2> /dev/null)"
    [ -n "$srcdir" ] && cp -r "$srcdir"/* "$bootdir/"
   fi
   bcd_backup="$bootdir"/BCD."$group"."$partname"
  # bios
  else
   bootdir="$(ls -d /mnt/[Bb][Oo][Oo][Tt])"
   bcd_backup="$bootdir"/BCD."$group"
  fi

  # restore bcd
  if [ -s "$bcd_backup" ]; then
   echo "Restauriere die Windows-$sysname-Bootkonfiguration aus $(basename "$bcd_backup")."
   cp -f "$bcd_backup" "$bootdir"/BCD
  fi

  # restore disk boot sector
  # detect old versions
  local bsmbr="$bootdir"/bsmbr."$group"
  local bsmbr_old="$bootdir"/winmbr446."$group"
  [ -e "$bsmbr_old" ] && mv "$bsmbr_old" "$bsmbr"
  [ -e "$bsmbr" ] || bsmbr="$bootdir"/winmbr."$group"
  [ -e "$bsmbr" ] || bsmbr="$bootdir"/win7mbr."$group"
  if [ -e "$bsmbr" ]; then
   echo -n "Restauriere den Disk-Bootsektor aus $(basename "$bsmbr")"
   case "$bsmbr" in
    *bsmbr.*)
     dd if="$bsmbr" of="$disk" bs=446 count=1 2>> /tmp/linbo.log
     ;;
    *winmbr.*)
     dd if="$bsmbr" of="$disk" bs=1 count=4 seek=440 2>> /tmp/linbo.log
     ;;
    *win7mbr.*)
     dd if="$bsmbr" of="$disk" bs=1 count=4 skip=440 2>> /tmp/linbo.log
     ;;
   esac
  fi
  local bsvbr="$bootdir"/bsvbr."$group"
  if [ -e "$bsvbr" ]; then
   echo " und $bsvbr."
   dd if="$bsvbr" of="$disk" bs=446 count=63 2>> /tmp/linbo.log   
  else
   echo "."
  fi

  # restore ntfs id
  [ -e "$bootdir"/ntfs.id ] && local ntfsid="$(ls "$bootdir"/ntfs.id 2> /dev/null)"
  if [ -n "$ntfsid" -a -s "$ntfsid" ]; then
   echo "Restauriere NTFS-ID $(basename "$ntfsid")."
   dd if="$ntfsid" of="$rootdev" bs=8 count=1 seek=9 2>> /tmp/linbo.log
  fi

  # write partition boot sector (vfat and 32bit only)
  if [ "$(fstype "$rootdev")" = "vfat" -a -z "$(get_64)" ]; then
   local msopt=""
   [ -e /mnt/[Nn][Tt][Ll][Dd][Rr] ] && msopt="-2"
   [ -e /mnt/[Ii][Oo].[Ss][Yy][Ss] ] && msopt="-3"
   if [ -n "$msopt" ]; then
    echo "Schreibe Partitionsbootsektor." | tee -a /tmp/patch.log
    ms-sys "$msopt" "$rootdev" | tee -a /tmp/patch.log
   fi
  fi

  # update linuxmuster-win scripts and restore windows activation
  if [ -d /cache/linuxmuster-win ]; then
   update_win || RC="1"
   if [ "$RC" = "0" ]; then
    restore_winact || RC="1"
   fi
  fi

 fi # windows stuff end

 # linux stuff begin

 # grub efi
 if [ -n "$efipart" -a -d /mnt/boot/grub ]; then
  mkdir -p /mnt/boot/efi
  mount "$efipart" /mnt/boot/efi
  local i
  for i in /dev /dev/pts /proc /sys; do
   mount --bind "$i" /mnt"$i"
  done
  chroot /mnt update-grub
  for i in /sys /proc /dev/pts /dev; do
   umount /mnt"$i"
  done
  umount /mnt/boot/efi
 fi

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

 # linux stuff end

 # opsi stuff
 do_opsi "$2" "$3" || RC="1"

 # source postsync script
 [ -s "/cache/$postsync" ] && . "/cache/$postsync"

 # finally do minimal boot configuration
 mk_boot || RC=1

 # all done
 sync; sync; sleep 1
 umount /mnt || umount -l /mnt
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
 # ntfsfix before image creation
 #[ "$type" = "ntfs" ] && ntfsfix -d "$5"
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
  echo "Download von $image wegen Zeitueberschreitung abgebrochen." >&2 | tee -a /tmp/image.log
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
 local OPTS="-I $ip -M $MAX_INITIATE -z $SLICE_SIZE"
 [ $MAX_UPLOAD_RATE -gt 0 ] && OPTS="$OPTS -U $MAX_UPLOAD_RATE"
 echo "Torrent-Optionen: $OPTS" >> /tmp/image.log
 echo "Starte Torrent-Dienst fuer $image." | tee -a /tmp/image.log
 local logfile=/tmp/"$image".log
 if [ ! -e "$complete" ]; then
  rm -f "$image" "$torrent".bf
  torrent_watchdog "$image" "$TIMEOUT" &
  interruptible ctorrent -e 0 $OPTS -X "touch $complete" "$torrent" | tee -a "$logfile"
 fi
 # start seeder if download is complete
 if [ -e "$complete" ]; then
  RC=0
  ctorrent -e 100000 $OPTS -f -d "$torrent"
 fi
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
    echo "Server enthaelt eine neuere ($ts2) Version von $2 ($ts1)."
   elif  [ -n "$fs1" -a -n "$fs2" -a ! "$fs1" -eq "$fs2" ] >/dev/null 2>&1; then
    DOWNLOAD_ALL="true"
    echo "Dateigroesse von $2 ($fs1) im Cache ($fs2) stimmt nicht."
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
  download_all "$1" "$2".reg >/dev/null 2>&1
  download_all "$1" "$2".postsync >/dev/null 2>&1
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
     [ "$RC" = "0" ] ||  echo "Download von $2 per Torrent fehlgeschlagen!" >&2
    ;;
    multicast)
     if [ -s /multicast.list ]; then
      local MPORT="$(get_multicast_port "$2")"
      if [ -n "$MPORT" ]; then
       download_multicast "$1" "$MPORT" "$2" ; RC="$?"
      else
       echo "Konnte Multicast-Port nicht bestimmen, kein Multicast-Download moeglich." >&2
       RC=1
      fi
     else
      echo "Datei multicast.list nicht gefunden, kein Multicast-Download moeglich." >&2
      RC=1
     fi
     [ "$RC" = "0" ] || echo "Download von $2 per multicast fehlgeschlagen!" >&2
    ;;
   esac
   # download per rsync also as a fallback if other download types failed
   if [ "$RC" != "0" -o "$DLTYPE" = "rsync" ]; then
    [ "$RC" = "0" ] || echo "Versuche Download per RSYNC." >&2
    download_all "$1" "$2" ; RC="$?"
    [ "$RC" = "0" ] || echo "Download von $2 per RSYNC fehlgeschlagen!" >&2
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
  echo "Keine neuere Version vorhanden, ueberspringe $2."
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
  echo "hoechstwahrscheinlich bereits auf dem Server, daher kein Upload." | tee -a /tmp/linbo.log
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
  for ext in info postsync reg desc torrent; do
   [ -s "${5}.${ext}" ] && FILES="$FILES ${5}.${ext}"
  done
  echo "Lade $FILES auf $1 hoch ..." | tee -a /tmp/linbo.log
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
  echo "Cache $2 ist nicht lokal, ueberspringe Aktualisierung der Images."
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

# update server cachedev force
# updates grub and linbo stuff
update(){
 # do not execute in localmode
 localmode && return 0

 echo -n "update " ;  printargs "$@"
 local doneflag="/tmp/.update.done"
 local force="$3"

 if [ -e "$doneflag" -a -z "$force" ]; then
  echo "LINBO-Update wurde schon ausgefuehrt!"
  return 0
 else
  rm -f "$doneflag"
 fi

 local rebootflag="/tmp/.linbo.reboot"
 local reboot
 local RC=0
 local group="$(hostgroup)"
 local server="$1"
 local cachedev="$2"
 local disk="${cachedev%%[1-9]*}"
 local grubdir="/cache/boot/grub"
 mountcache "$cachedev" || return 1
 mkdir -p "$grubdir"

 cd /cache
 local suffix="$(get_64)"
 # detect non pae cpu
 if [ -z "$suffix" ]; then
  grep ^flags /proc/cpuinfo | head -1 | grep -wq pae || suffix="-np"
 fi
 local kernel="linbo${suffix}"
 local kernelfs="linbofs${suffix}.lz"
 local md5_before
 local md5_after
 local md5_current
 local i
 local myname="$(clientname)"

 # local restore of start.conf in cache (necessary if cache partition was formatted before)
 [ -s start.conf ] || cp /start.conf .

 # check for linbo/linbofs updates on server
 # download newer linbo/linbofs if applicable and check download
 echo "Pruefe auf LINBO-Aktualisierungen."
 for i in "$kernel" "$kernelfs"; do
  md5_before="" ; md5_after="" ; md5_current=""
  [ -s "$i" ] && md5_before="$(md5sum "$i" | awk '{ print $1 }')"
  rm -f "${i}.md5"
  download "$server" "${i}.md5" && md5_after="$(cat "$i".md5 2> /dev/null)"
  if [ -z "$md5_after" ]; then
   echo "Download-Fehler bei ${i}.md5!" >&2
   rm -f "$kernel" "$kernelfs" "${kernel}.md5" "${kernelfs}.md5"
   return 1
  fi
  if [ -z "$md5_before" -o "$md5_before" != "$md5_after" ]; then
   download "$server" "$i" && md5_current="$(md5sum "$i" | awk '{ print $1 }')"
   if [ "$md5_after" = "$md5_current" ]; then
    echo "$i wurde erfolgreich aktualisiert."
    reboot="yes"
   else
    echo "Download-Fehler bei $i!" >&2
    rm -f "$kernel" "$kernelfs" "${kernel}.md5" "${kernelfs}.md5"
    return 1
   fi
  else
   echo "$i ist aktuell."
  fi
 done

 # get group specific and local grub configs from server
 echo "Aktualisiere GRUB-Konfiguration."
 for i in boot/grub/ipxe.lkrn "boot/grub/$group.cfg" "boot/grub/spool/$myname.$group.grub.cfg"; do
  # collect md5 before download
  if [ "$i" = "boot/grub/$group.cfg" ]; then
   md5_before="$(md5sum "$grubdir/custom.cfg" 2> /dev/null | awk '{ print $1 }')"
  elif [ "$i" = "boot/grub/spool/$myname.$group.grub.cfg" ]; then
   md5_before="$(md5sum "$grubdir/grub.cfg" 2> /dev/null | awk '{ print $1 }')"
  else
   md5_before="$(md5sum "$(basename "$i")" 2> /dev/null | awk '{ print $1 }')"
  fi
  download "$server" "$i" || RC=1
  if [ "$RC" = "1" ]; then
   echo "Download-Fehler bei $i!" >&2
   rm -f "$i"
   return 1
  fi
  # collect md5 after download
  md5_after="$(md5sum "$(basename "$i")" 2> /dev/null | awk '{ print $1 }')"
  # if md5 differ, reboot
  if [ "$md5_before" != "$md5_after" ]; then
   echo "$(basename "$i") wurde aktualisiert."
   reboot="yes"
  fi
 done

 # move downloads in place
 mv "$group.cfg" "$grubdir/custom.cfg" || RC=1
 mv "$myname.$group.grub.cfg" "$grubdir/grub.cfg" || RC=1
 if [ "$RC" = "1" ]; then
  echo "Fehler beim Schreiben der GRUB-Konfigurationsdateien!" >&2
  return 1
 fi

 # keep grub themes also updated
 echo -n "Aktualisiere GRUB-Themes ... "
 themesdir="/boot/grub/themes"
 mkdir -p "/cache$themesdir"
 rsync -a --delete "${server}::linbo${themesdir}/" "/cache${themesdir}/" || RC=1
 if [ "$RC" = "1" ]; then
  echo "Fehler!" >&2
  return 1
 else
  echo "OK!"
 fi

 # fetch also current linuxmuster-win scripts
 echo -n "Aktualisiere linuxmuster-win ... "
 [ -d /cache/linuxmuster-win ] || mkdir -p /cache/linuxmuster-win
 rsync -a --exclude=*.ex --delete --delete-excluded "$server::linbo/linuxmuster-win/" /cache/linuxmuster-win/ || RC=1
 if [ "$RC" = "1" ]; then
  echo "Fehler!" >&2
  return 1
 else
  echo "OK!"
 fi

 # finally update/install grub stuff
 if mk_boot; then

  # remove for old legacy grub stuff
  if [ -e "$grubdir/stage1" -o -e "$grubdir/menu.lst" ]; then
   echo "Entferne GRUB legacy, Reboot wird notwendig."
   rm -f "$grubdir"/*stage* "$grubdir"/menu.lst gpxe.krn
   if [ -e /cache/update.log ]; then
    cat /cache/update.log >> /tmp/linbo.log
    sendlog
   fi
   ( umount -a ; /sbin/reboot -f )
  fi

 else
  RC="1"
 fi

 if [ "$RC" = "0" ]; then
  echo "LINBO/GRUB update fertig."
  touch "$doneflag"
  [ -n "$reboot" ] && touch "$rebootflag"
 else
  echo "Fehler!" >&2
 fi

 sendlog
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
   echo "Entferne nicht mehr benoetigte Imagedatei $i." | tee -a /tmp/image.log
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
   echo "Zeitueberschreitung, LINBO noch nicht fertig. :-(" >&2
   return 1
  fi
 done
 localmode || echo "Netzwerk OK."
 echo "Lokale Festplatte(n) OK."
 return 0
}

mac(){
 local iface
 local mac
 iface="$(LANG=C route | grep ^default | awk '{ print $8 }' 2> /dev/null)"
 [ -n "$iface" ] && mac="$(LANG=C ifconfig "$iface" | grep HWaddr | awk '{print $5}' | tr a-z A-Z)"
 [ -z "$mac" ] && mac="OFFLINE"
 echo "$mac"
}

# Find all available batteries, get their capacity and output capacity of first found battery
battery()
{
 find /sys/class/power_supply/ -name 'BAT*' -exec cat {}/capacity \; | head -n 1
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
 local info="$room;$client;$group;$macaddr;$ip;;;;;1;1"
 # Plausibility check
 if echo "$client" | grep -qi '[^a-z0-9-]'; then
  echo "Falscher Rechnername: '$client'," >&2
  echo "Rechnernamen duerfen nur Buchstaben [a-z0-9-] enthalten." >&2
  return 1
 fi
 if echo "$group" | grep -qi '[^a-z0-9_]'; then
  echo "Falscher Gruppenname: '$group'," >&2
  echo "Rechnergruppen duerfen nur Buchstaben [a-z0-9_] enthalten." >&2
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
 local iface
 local ip
 iface="$(LANG=C route | grep ^default | awk '{ print $8 }' 2> /dev/null)"
 [ -n "$iface" ] && ip="$(LANG=C ifconfig "$iface" | grep 'inet addr:' | awk -F\: '{ print $2 }' | awk '{ print $1 }')"
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
  local d=$(get_partition_size "$1")
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
 battery) battery ;;
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
 fstype) fstype "$@" ;;
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
