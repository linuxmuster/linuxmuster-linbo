#!/bin/bash
#
# exec linbo commands remote per ssh
#
# Thomas Schmitt <schmitt@lmz-bw.de>
#
# GPL V3
#
# $Id$
#

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

SSH=linbo-ssh
SCP=linbo-scp
WRAPPER=/usr/bin/linbo_wrapper
REMOTE_TAG="### LINBO REMOTE ###"
ETHERWAKE="$(which etherwake)"
TMPDIR=/var/tmp

# usage info
usage(){
 echo
 echo "Usage: `basename $0` <options>"
 echo
 echo "Options:"
 echo
 echo " -h                 Show this help."
 echo " -b <sec>           Wait <sec> second(s) between the sending of wake-on-lan"
 echo "                    magic packets."
 echo "                    to the client(s). Implies -w to be set also."
 echo " -c <cmd1,cmd2,...> Comma separated list of linbo commands to be transfered to"
 echo "                    the client(s)."
 echo " -g <group>         All members of this hostgroup will be processed."
 echo " -i <ip|hostname>   Only the client with this ip or hostname will be processed."
 echo " -l                 List current linbo-remote screens."
 echo " -r <room>          All members of this room will be processed."
 echo " -w <sec>           Send wake-on-lan magic packets to the client(s) and wait"
 echo "                    <sec> seconds before executing the commands to be sure the"
 echo "                    clients have booted."
 echo
 echo "Important: Options -r, -g and -i exclude each other mutually."
 echo
 echo "Supported commands for -c option are:"
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
 echo "reboot                   : Reboots the client."
 echo "halt                     : Shuts the client down."
 echo
 echo "<\"msg\"> is an optional image comment."
 echo "The position numbers are related to the position in start.conf."
 echo "The commands were sent per ssh to the linbo_wrapper on the client and processed in the order given on the commandline."
	exit 1
}

# list linbo-remote screens
list(){
 local line=""
 local pid=""
 local screen=""
 local status=""
 local c=0
 local d=""
 screen -wipe | grep .linbo-remote | while read line; do
  let c+=1
  pid="$(echo $line | awk -F\. '{ print $1 }' | awk '{ print $1 }')"
  screen="$(echo $line | awk '{ print $1 }')"
  screen="${screen#*.}"
  status="$(echo $line | awk '{ print $2 }')"
  d=""
  [ $c -lt 100 ] && d=" "
  [ $c -lt 10 ] && d="  "
  echo -e "$d$c\t$pid\t$screen\t$status"
 done
}

# process cmdline
while getopts ":b:c:g:hi:lr:w:" opt; do
 case $opt in
  l) list
     exit 0 ;;
  b) BETWEEN=$OPTARG ;;
  c) CMDS=$OPTARG
     case "$CMDS" in *upload*|*create*) SECRETS=/etc/rsyncd.secrets ;; esac ;;
  i) IP=$OPTARG ;;
  g) GROUP=$OPTARG ;;
  r) ROOM=$OPTARG ;;
  w) WAIT=$OPTARG ;;
  h) usage ;;
  \?) echo "Invalid option: -$OPTARG" >&2
      usage ;;
  :) echo "Option -$OPTARG requires an argument." >&2
     usage ;;
 esac
done

# check options
[ -z "$GROUP" -a -z "$IP" -a -z "$ROOM" ] && usage
[ -n "$GROUP" -a -n "$IP" ] && usage
[ -n "$GROUP" -a -n "$ROOM" ] && usage
[ -n "$IP" -a -n "$ROOM" ] && usage
[ -z "$CMDS" ] && usage
if [ -n "$WAIT" ]; then
 isinteger "$WAIT" || usage
 if [ ! -x "$ETHERWAKE" ]; then
  echo "$ETHERWAKE not found!"
  exit 1
 fi
fi
if [ -n "$BETWEEN" ]; then
 [ -z "$WAIT" ] && usage
 isinteger "$BETWEEN" || usage
fi
CMDS="${CMDS//,/ }"

# evaluate ip / group / room
if [ -n "$IP" ]; then
 if ! validip "$IP"; then
  HOSTNAME="$IP"
  get_ip "$HOSTNAME"
  IP="$RET"
  [ -z "$IP" ] && usage
 else
  get_hostname "$IP"
  HOSTNAME="$RET"
  [ -z "$HOSTNAME" ] && usage
 fi
elif [ -n "$GROUP" ]; then # group
 IP="$(grep -v ^# $WIMPORTDATA | awk -F\; '{ print $3, $5, $11 }' | grep ^"$GROUP " | grep -v " 0" | awk '{ print $2 }')"
 [ -z "$IP" ] && usage
else # room
 IP="$(grep -v ^# $WIMPORTDATA | awk -F\; '{ print $1, $5, $11 }' | grep ^"$ROOM " | grep -v " 0"  | awk '{ print $2 }')"
 [ -z "$IP" ] && usage
fi

# temporarily replace start.conf's in remote control mode
replace_startconfs(){
 for i in $STARTCONF; do
  # check if start.conf exists for remote tag
  if [ ! -e "$i" ]; then
   echo "Fatal: `basename $i` not found!"
   exit 1
  fi
  # check for remote tag
  if grep "$REMOTE_TAG" "$i"; then
   echo "Remote tag in `basename $i` detected! Aborting!"
   exit 1
  fi
 done
 # start processing after checks
 echo "Replacing"
 local BACKUPCONF=""
 for i in $STARTCONF; do
  echo " $(basename "$i") ..."
  # move start.conf
  BACKUPCONF="$i.$$"
  [ -e "$BACKUPCONF" ] && rm -rf "$BACKUPCONF"
  mv "$i" "$BACKUPCONF"
  # set remote tag
  echo "$REMOTE_TAG" > "$i"
  # convert to utf8 and remove comments and empty lines
  iconv -f latin1 -t utf-8 "$BACKUPCONF" | sed -e 's/#.*//' -e 's/[ ^I]*$//' -e '/^$/ d' >> "$i"
  # disable start automatisms and buttons
  sed -e 's|^[Aa][Uu][Tt][Oo][Pp][Aa][Rr][Tt][Ii][Tt][Ii][Oo][Nn].*|AutoPartition = no|g
          s|^[Aa][Uu][Tt][Oo][Ff][Oo][Rr][Mm][Aa][Tt].*|AutoFormat = no|g
          s|^[Aa][Uu][Tt][Oo][Ii][Nn][Ii][Tt][Cc][Aa][Cc][Hh][Ee].*|AutoInitCache = no|g
          s|^[Ss][Tt][Aa][Rr][Tt][Ee][Nn][Aa][Bb][Ll][Ee][Dd].*|StartEnabled = no|g
          s|^[Ss][Yy][Nn][Cc][Ee][Nn][Aa][Bb][Ll][Ee][Dd].*|SyncEnabled = no|g
          s|^[Nn][Ee][Ww][Ee][Nn][Aa][Bb][Ll][Ee][Dd].*|NewEnabled = no|g
          s|^[Aa][Uu][Tt][Oo][Ss][Tt][Aa][Rr][Tt].*|Autostart = no|g' -i "$i"
 done
}

# script header info
echo "###"
echo "### linbo-remote ($$) start: $(date)"
echo "###"

# wake-on-lan stuff
if [ -n "$WAIT" ]; then
 # check interface
 iface="$(route | grep ^default | awk '{ print $8 }')"
 if [ -z "$iface" ]; then
  echo "Default route not found. Cannot determine network interface!"
  exit 1
 fi
 # get start.conf's
 if [ -n "$GROUP" ]; then
  STARTCONF="$LINBODIR/start.conf.$GROUP"
 else
  for i in $IP; do
   STARTCONF="$STARTCONF $LINBODIR/start.conf-$i"
  done
 fi
 # replace start.conf's for remote control mode
 replace_startconfs
 # wake-on-lan
 echo "Waking up"
 for i in $IP; do
  echo " $i ..."
  get_mac "$i"
  $ETHERWAKE -i "$iface" "$RET"
  [ -n "$BETWEEN" ] && sleep "$BETWEEN"
 done
 # wait
 echo "Waiting $WAIT second(s) for client(s) to boot ..."
 sleep "$WAIT"
fi

# send commands
echo "Sending command(s) \"$CMDS\" to"
for i in $IP; do
 echo -n " $i ... "
 if $SSH $i ls /start.conf &> /dev/null; then
  if [ -n "$SECRETS" ]; then
   echo -n "uploading secrets ... "
   $SCP $SECRETS ${i}:/tmp
  fi
  get_hostname "$i"
  HOSTNAME="$RET"
  # create a temporary script with linbo remote commands
  REMOTESCRIPT=$TMPDIR/$$.$HOSTNAME.sh
  echo "#!/bin/sh" > $REMOTESCRIPT
  for c in $CMDS; do
   case $c in
    start:*|reboot|halt|poweroff)
     START=yes
     echo "$SSH $i $WRAPPER $c &" >> $REMOTESCRIPT
     echo "sleep 10" >> $REMOTESCRIPT ;;
    *) echo "$SSH $i $WRAPPER $c" >> $REMOTESCRIPT ;;
   esac
  done
  [ -n "$SECRETS" -a -z "$START" ] && echo "$SSH $i /bin/rm /tmp/rsyncd.secrets" >> $REMOTESCRIPT
  echo "rm $REMOTESCRIPT" >> $REMOTESCRIPT
  echo "exit 0" >> $REMOTESCRIPT
  chmod 755 $REMOTESCRIPT
  screen -dmS $HOSTNAME.linbo-remote $REMOTESCRIPT
  echo "Ok!"
 else
  echo "Failed!"
 fi
done

# restore start.conf
if [ -n "$WAIT" ]; then
 echo "Restoring"
 for i in $STARTCONF; do
  echo " $(basename "$i") ..."
  BACKUPCONF="$i.$$"
  mv "$BACKUPCONF" "$i"
 done
fi

# script footer info
echo "###"
echo "### linbo-remote ($$) end: $(date)"
echo "###"

exit 0

