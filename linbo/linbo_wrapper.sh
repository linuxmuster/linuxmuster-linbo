#!/bin/sh
#
# wrapper for linbo_cmd
#
# thomas@linuxmuster.net
# 09.10.2014
# GPL V3
#

ARGS="$@"

[ -z "$ARGS" ] && exit 0

# check for concurrent processes
if ps w | grep linbo_cmd | grep -v grep; then
 echo "There is already a linbo_cmd process running. Aborting!"
 exit 1
fi

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
SECRETS=/tmp/rsyncd.secrets

# test if variable is an integer
isinteger () {
 [ $# -eq 1 ] || return 1
 case $1 in
 *[!0-9]*|"") return 1;;
           *) return 0;;
 esac
}

# get server ip
get_server(){
 server=`grep ^linbo_server /tmp/dhcp.log | awk -F\' '{ print $2 }'`
 if [ -z "$server" ]; then
  echo "Cannot determine server ip!"
  exit 1
 fi
 echo "$server"
}

# get cache device
get_cachedev(){
 cachedev=`grep -i ^cache /start.conf | tail -1 | awk -F\= '{ print $2 }' | awk '{ print $1 }'`
 echo "$cachedev"
}

# get downloadtype
get_downloadtype(){
 downloadtype=`grep -i ^downloadtype /start.conf | tail -1 | awk -F\= '{ print $2 }' | awk '{ print $1 }'`
 [ -z "$downloadtype" ] && downloadtype=rsync
 echo "$downloadtype"
}

# get image names
get_images(){
 local baseimages=`grep -i ^baseimage /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }'`
 local diffimages=`grep -i ^image /start.conf | awk -F\= '{ print $2 }' | awk '{ print $1 }'`
 [ -n "$baseimages" -a -n "$diffimages" ] && images="$baseimages $diffimages"
 [ -n "$baseimages" -a -z "$diffimages" ] && images="$baseimages"
 echo "$images"
}

# get baseimage name
get_os(){
 # check for valid start.conf
 if ! grep -qi ^"\[os\]" /start.conf; then
  echo "Error! No os definitions found in start.conf!"
  return 1
 fi
 local line=""
 local c=0
 local param=""
 local value=""
 osname=""
 baseimage=""
 image=""
 bootdev=""
 rootdev=""
 kernel=""
 initrd=""
 append=""
 while read line; do
  # strip trailing comments
  line="${line%\#*}"
  # strip trailing spaces
  line="$(echo "$line" | sed 's/[ \t]*$//')"
  # skip lines beginning with comment
  [ "${line:0:1}" = "#" ] && continue
  # skip empty lines
  [ -z "$line" ] && continue
  # find [OS] entry at position given in $osnr
  case "$line" in
   \[[Oo][Ss]\])
    let c+=1
    if [ $c -gt $osnr ]; then
     return 0
    else
     continue
    fi
   ;;
  esac
  # parse os definition
  if [ $c -eq $osnr ]; then
   param="$(echo $line | awk -F\= '{ print $1 }' | sed 's/[ \t]*$//')"
   value="$(echo "$line" | sed "s/$param//" | sed "s/^[ \t]*//" | sed "s/^=//" | sed "s/^[ \t]*//" | awk -F\# '{ print $1 }' | sed "s/ *$//g")"
   case "$param" in
    [Nn][Aa][Mm][Ee]) osname="$value" ;;
    [Ii][Mm][Aa][Gg][Ee]) image="$value" ;;
    [Bb][Aa][Ss][Ee][Ii][Mm][Aa][Gg][Ee]) baseimage="$value" ;;
    [Bb][Oo][Oo][Tt]) bootdev="$value" ;;
    [Rr][Oo][Oo][Tt]) rootdev="$value" ;;
    [Kk][Ee][Rr][Nn][Ee][Ll]) kernel="$value" ;;
    [Ii][Nn][Ii][Tt][Rr][Dd]) initrd="$value" ;;
    [Aa][Pp][Pp][Ee][Nn][Dd]) append="$value" ;;
   esac
  fi
 done < /start.conf
} # get_os

# print value of start.conf parameter
stripvalue(){
 local line="$1"
 local ret="$(echo $line | awk -F\= '{ print $2 }')"
 [ -z "$ret" ] && ret="-"
 echo "$ret"
}

# get partition data
get_partitions() {
 # check for valid start.conf
 if ! grep -qi ^"\[partition\]" /start.conf; then
  echo "Error! No partition definitions found in start.conf!"
  return 1
 fi
 if ! grep -qi ^"\[os\]" /start.conf; then
  echo "Error! No os definitions found in start.conf!"
  return 1
 fi
 # define local variables
 local dev=""
 local size=""
 local pid=""
 local fstype=""
 local bootable=""
 local line=""
 partitions=""
 # parse start.conf and store partition definitions in /tmp/partitions
 grep ^[\[DdSsIiBbFf][PpEeIiDdOoSs] /start.conf | tr A-Z a-z | sed 's/ //g' | sed -e 's/#.*$//' | while read line; do
  case "$line" in
   \[partition\]*|\[os\]*)
    if [ -n "$dev" -a -n "$size" -a -n "$pid" ]; then
     [ -z "$bootable" ] && bootable="-"
     [ -z "$fstype" ] && fstype="-"
     partitions="$partitions $dev $size $pid $bootable $fstype"
     echo "$partitions" > /tmp/partitions
    fi
    [ "$line" = "\[os\]" ] && break
    dev=""; size=""; pid=""; bootable=""; fstype=""
   ;;
   dev=*) dev="$(stripvalue "$line")" ;;
   size=*)
    size="$(stripvalue "$line")"
    isinteger "$size" || size=0
   ;;
   id=*) pid="$(stripvalue "$line")" ;;
   bootable=*)
    bootable="$(stripvalue "$line")"
    [ "$bootable" = "yes" ] && bootable="bootable"
   ;;
   fstype=*) fstype="$(stripvalue "$line")" ;;
   *) ;;
  esac
 done
 partitions="$(cat /tmp/partitions)"
} # get_partitions

# format a specific partition
format_partition(){
 local pos=$((((1))+$(($partnr-1))*((5))))
 local dev="$(echo $partitions | cut -d" " -f$pos)"
 pos=$(($partnr*5))
 local fstype="$(echo $partitions | cut -d" " -f$pos)"
 local fcmd=""
 case "$fstype" in
  [Ss][Ww][Aa][Pp]) fcmd="mkswap $dev" ;;
  [Rr][Ee][Ii][Ss][Ee][Rr][Ff][Ss]) fcmd="mkreiserfs -f -f  $dev" ;;
  [Ee][Xx][Tt][234]) fcmd="mkfs.$fstype $dev" ;;
  [Nn][Tt][Ff][Ss]) fcmd="mkfs.ntfs -Q $dev" ;;
  [Vv][Ff][Aa][Tt]) fcmd="mkdosfs -F 32 $dev" ;;
  *) echo "Unknown filesystem: $fstype!"
     return 1 ;;
 esac
 if [ -n "$fcmd" ]; then
  # abort if partitioning fails
  if ! linbo_cmd partition_noformat $partitions; then
   echo "Partitioning error ... aborting!"
   return 1
  fi
  # test if device is present after partitioning, if not wait 3 secs
  if [ ! -b "$dev" ]; then
   echo "Partition $dev is not yet ready ... waiting 3 seconds ..."
   sleep 3
  fi
  # test again, abort if device is not there
  if [ ! -b "$dev" ]; then
   echo "Partition $dev does not exist ... aborting!"
   return 1
  fi
  if ! $fcmd; then
   echo "Error on formatting $dev ... aborting!"
   return 1
  fi
 fi
}

# get rsync user and password
get_passwd(){
 [ -s "$SECRETS" ] || return 1
 user=linbo
 password="$(grep ^"$user:" "$SECRETS" | awk -F\: '{ print $2 }')"
}

# creates image description
create_desc(){
 local image="$1"
 linbo_cmd mountcache "$cachedev" -w
 cat /proc/mounts | grep -q /cache || return 1
 if [ -n "$msg" ]; then
  msg="$(date): $msg"
 else
  msg="$(date): $image created by linbo_wrapper."
 fi
 echo "$msg" > /cache/msg.tmp
 [ -s "/cache/$image.desc" ] && cat "/cache/$image.desc" >> /cache/msg.tmp
 mv /cache/msg.tmp "/cache/$image.desc"
}

# print help
help(){
 echo
 echo "Usage: `basename $0` <command1 command2 ...>"
 echo
 echo "`basename $0` allows the use of linbo_cmd easyly on the commandline."
 echo "It reads the start.conf file and builds the commands accordingly."
 echo
 echo "Allowed commands are:"
 echo
 echo "partition                : Writes the partition table."
 echo "format                   : Writes the partition table and formats all"
 echo "                           partitions."
 echo "format:<#>               : Writes the partition table and formats only"
 echo "                           partition nr <#>."
 echo "initcache:<dltype>       : Updates local cache. <dltype> is one of"
 echo "                           rsync|multicast|torrent."
 echo "                           If dltype is not specified it is read from"
 echo "                           start.conf."
 echo "sync:<#>                 : Syncs the operating system on position nr <#>."
 echo "start:<#>                : Starts the operating system on pos. nr <#>."
 echo "create_cloop:<#>:<\"msg\"> : Creates a cloop image from operating system nr <#>."
 echo "create_rsync:<#>:<\"msg\"> : Creates a rsync image from operating system nr <#>."
 echo "upload_cloop:<#>         : Uploads the cloop image from operating system nr <#>."
 echo "upload_rsync:<#>         : Uploads the rsync image from operating system nr <#>."
 echo "update                   : Update the kernel,initrd and install grub to MBR"
 echo "reboot                   : Reboots the client."
 echo "halt                     : Shuts the client down."
 echo "help                     : Shows this page."
 echo
 echo "<\"msg\"> is an optional image comment."
 echo "The position numbers are related to the position in start.conf."
 echo "The commands are processed in the commandline given order."
 echo "The upload commands expect a file /tmp/rsyncd.secrets with rsync credentials"
 echo "in the form:"
 echo "user:password"
 echo
 exit
}

case "$@" in *help*) help ;; esac

# process command line args
while [ "$#" -gt "0" ]; do

 cmd=`echo "$1" | awk -F\: '{ print $1 }'`
 param=`echo "$1" | awk -F\: '{ print $2 }'`
 msg=`echo "$1" | awk -F\: '{ print $3 }'`
 customimage=`echo "$1" | awk -F\: '{ print $4 }'`

 # do not print linbo password
 echo "command      : $cmd"
 [ -n "$param" -a "$cmd" != "linbo" ] && echo "parameter    : $param"
 [ -n "$msg" ] && echo "comment      : $msg"
 [ -n "$customimage" ] && echo "custom image : $customimage"

 case "$cmd" in

  linbo)
   echo "${cmd}:${param}" > "$SECRETS"
   ;;

  partition)
   get_partitions
   [ -n "$partitions" ] && linbo_cmd partition_noformat $partitions
  ;;

  format)
   get_partitions
   if [ -n "$partitions" ]; then
    if [ -z "$param" ]; then
     linbo_cmd partition $partitions
    else
     partnr="$param"
     if isinteger "$partnr" && [ $partnr -gt 0 ]; then
      format_partition
     fi
    fi
   fi 
  ;;

  initcache)
   [ -z "$server" ] && get_server
   [ -z "$cachedev" ] && get_cachedev
   if [ "$param" = "rsync" -o "$param" = "multicast" -o "$param" = "torrent" ]; then
    downloadtype="$param"
   else
    get_downloadtype
   fi
   get_images
   if [ -n "$server" -a -n "$cachedev" -a -n "$images" ]; then
    linbo_cmd initcache $server $cachedev $downloadtype $images
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Initcache command was: linbo_cmd initcache $server $cachedev $downloadtype $images"
   fi
  ;;

  create_cloop)
   osnr="$param"
   if ! isinteger "$osnr"; then
    echo "$osnr is not an integer!"
    shift
    continue
   fi
   get_os
   echo "Creating $baseimage from $osname ..."
   [ -z "$cachedev" ] && get_cachedev
   [ -n "$customimage" ] && baseimage="$customimage"
   if [ -n "$cachedev" -a -n "$baseimage" -a -n "$bootdev" -a -n "$rootdev" -a -n "$kernel" ]; then
    create_desc "$baseimage"
    linbo_cmd create "$cachedev" "$baseimage" "" "$bootdev" "$rootdev" "$kernel" "$initrd"
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Create command was: linbo_cmd create $cachedev $baseimage $bootdev $rootdev $kernel $initrd"
   fi
  ;;

  upload_cloop)
   osnr="$param"
   if ! isinteger "$osnr"; then
    echo "$osnr is not an integer!"
    shift
    continue
   fi
   get_os
   get_passwd
   echo "Uploading $baseimage to $server ..."
   [ -z "$server" ] && get_server
   [ -z "$cachedev" ] && get_cachedev
   [ -n "$customimage" ] && baseimage="$customimage"
   if [ -n "$server" -a -n "$user" -a -n "$password" -a -n "$cachedev" -a -n "$baseimage" ]; then
    linbo_cmd upload "$server" "$user" "$password" "$cachedev" "$baseimage"
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Upload command was: linbo_cmd upload $server $user $password $cachedev $baseimage"
   fi
  ;;

  create_rsync)
   osnr="$param"
   if ! isinteger "$osnr"; then
    echo "$osnr is not an integer!"
    shift
    continue
   fi
   get_os
   echo "Creating $image from $osname ..."
   [ -z "$cachedev" ] && get_cachedev
   [ -n "$customimage" ] && image="$customimage"
   if [ -n "$cachedev" -a -n "$image" -a -n "$baseimage" -a -n "$bootdev" -a -n "$rootdev" -a -n "$kernel" ]; then
    create_desc "$image"
    linbo_cmd create "$cachedev" "$image" "$baseimage" "$bootdev" "$rootdev" "$kernel" "$initrd"
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Create command was: linbo_cmd create $cachedev $image $bootdev $rootdev $kernel $initrd"
   fi
  ;;

  upload_rsync)
   osnr="$param"
   if ! isinteger "$osnr"; then
    echo "$osnr is not an integer!"
    shift
    continue
   fi
   get_os
   get_passwd
   echo "Uploading $image to $server ..."
   [ -z "$server" ] && get_server
   [ -z "$cachedev" ] && get_cachedev
   [ -n "$customimage" ] && image="$customimage"
   if [ -n "$server" -a -n "$user" -a -n "$password" -a -n "$cachedev" -a -n "$image" ]; then
    linbo_cmd upload "$server" "$user" "$password" "$cachedev" "$image"
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Upload command was: linbo_cmd upload $server $user $password $cachedev $image"
   fi
  ;;

  sync)
   osnr="$param"
   if ! isinteger "$osnr"; then
    echo "$osnr is not an integer!"
    shift
    continue
   fi
   get_os
   echo "Syncing $osname ..."
   [ -z "$server" ] && get_server
   [ -z "$cachedev" ] && get_cachedev
   if [ -n "$server" -a -n "$cachedev" -a -n "$baseimage" -a -n "$bootdev" -a -n "$rootdev" -a -n "$kernel" ]; then
    linbo_cmd synconly "$server" "$cachedev" "$baseimage" "$image" "$bootdev" "$rootdev" "$kernel" "$initrd" "$append"
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Sync command was: linbo_cmd synconly $server $cachedev $baseimage $image $bootdev $rootdev $kernel $initrd $append"
   fi
  ;;

  start)
   osnr="$param"
   if ! isinteger "$osnr"; then
    echo "$osnr is not an integer!"
    shift
    continue
   fi
   get_os
   echo "Starting $osname ..."
   [ -z "$cachedev" ] && get_cachedev
   if [ -n "$bootdev" -a -n "$rootdev" -a -n "$kernel" -a -n "$cachedev" ]; then
    linbo_cmd start "$bootdev" "$rootdev" "$kernel" "$initrd" "$append" "$cachedev"
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Start command was: linbo_cmd start $bootdev $rootdev $kernel $initrd $append $cachedev"
    exit 1
   fi
  ;;

  update)
   echo "Updating kernel,initrd and installing grub to MBR ..."
   [ -z "$server" ] && get_server
   [ -z "$cachedev" ] && get_cachedev
   if [ -n "$server" -a -n "$cachedev" ]; then
    linbo_cmd update "$server" "$cachedev"
   else
    echo "Failed! One or more necessary parameters are missing!"
    echo "Update command was: linbo_cmd update $server $cachedev"
    exit 1
   fi
  ;;

  reboot) /sbin/reboot ;;

  halt|poweroff) /sbin/poweroff ;;

 esac

 shift

done

exit 0

