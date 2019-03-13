#!/bin/bash
#
# exec linbo commands remote per ssh
#
# thomas@linuxmuster.net
# 20190313
# GPL V3
#

# read linuxmuster environment
source /usr/share/linuxmuster/defaults.sh || exit 1
source /usr/share/linuxmuster/linbo/helperfunctions.sh || exit 1

KNOWNCMDS="label partition format initcache sync start create_cloop create_rsync upload_cloop upload_rsync reboot halt"
DLTYPES="multicast rsync torrent"
SSH="/usr/sbin/linbo-ssh -o BatchMode=yes -o StrictHostKeyChecking=no"
SCP=/usr/sbin/linbo-scp
WRAPPER=/usr/bin/linbo_wrapper
WOL="$(which wakeonlan)"
TMPDIR=/var/tmp

# usage info
usage(){
 echo
 echo "Usage: `basename $0` <options>"
 echo
 echo "Options:"
 echo
 echo " -h                 Show this help."
 echo " -b <sec>           Wait <sec> second(s) between sending wake-on-lan magic"
 echo "                    packets to the particular hosts. Must be used in"
 echo "                    conjunction with \"-w\"."
 echo " -c <cmd1,cmd2,...> Comma separated list of linbo commands transfered"
 echo "                    per ssh direct to the client(s)."
 echo " -d                 Disables start, sync and new buttons on next boot."
 echo "                    To be used together with option -p."
 echo " -g <group>         All hosts of this hostgroup will be processed."
 echo " -i <ip|hostname>   Ip or hostname of client to be processed."
 echo " -l                 List current linbo-remote screens."
 echo " -n                 Bypasses a start.conf configured auto functions"
 echo "                    (partition, format, initcache, start) on next boot."
 echo "                    To be used together with option -p."
 echo " -r <room>          All hosts of this room will be processed."
 echo " -p <cmd1,cmd2,...> Create an onboot command file executed automatically"
 echo "                    once next time the client boots."
 echo " -w <sec>           Send wake-on-lan magic packets to the client(s)"
 echo "                    and wait <sec> seconds before executing the"
 echo "                    commands given with \"-c\" or in case of \"-p\" after"
 echo "                    the creation of the pxe boot files."
 echo
 echo "Important: * Options \"-r\", \"-g\" and \"-i\" exclude each other, \"-c\" and"
 echo "             \"-p\" as well."
 echo "           * Option \"-c\" together with \"-w\" bypasses start.conf configured"
 echo "             auto functions (partition, format, initcache, start) and disables"
 echo "             start, sync and new buttons on next boot automatically."
 echo
 echo "Supported commands for -c or -p options are:"
 echo
 echo "partition                : Writes the partition table."
 echo "label                    : Labels all partitions defined in start.conf."
 echo "                           Note: Partitions have to be formatted."
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
 echo "The commands were sent per ssh to the linbo_wrapper on the client and processed"
 echo "in the order given on the commandline."
 echo "create_* and upload_* commands cannot be used with -r and -g options."
 exit 1
}

# list linbo-remote screens
list(){
 local line=""
 local pid=""
 local c=0
 local d
 screen -wipe | grep .linbo-remote | sort | sed -e 's|\.|\t|' | while read line; do
  c=$(( c + 1 ))
  d=""
  [ $c -lt 100 ] && d=" "
  [ $c -lt 10 ] && d="  "
  echo -e "$d$c\t$line"
 done
}

# process cmdline
while getopts ":b:c:dg:hi:lnp:r:w:" opt; do

# debug
#echo "### opt: $opt $OPTARG"

 case $opt in
  l) list
     exit 0 ;;
  b) BETWEEN=$OPTARG ;;
  c) DIRECT=$OPTARG ;;
  d) NOBUTTONS=yes ;;
  i) IP=$OPTARG ;;
  g) GROUP=$OPTARG ;;
  p) ONBOOT=$OPTARG  ;;
  r) ROOM=$OPTARG ;;
  w) WAIT=$OPTARG
     isinteger "$WAIT" || usage ;;
  n) NOAUTO=yes ;;
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
[ -n "$DIRECT" -a -n "$ONBOOT" ] && usage
[ -z "$DIRECT" -a -z "$ONBOOT" -a -z "$WAIT" ] && usage
if [ -n "$WAIT" ]; then
 if [ ! -x "$WOL" ]; then
  echo "$WOL not found!"
  exit 1
 fi
 [ -n "$DIRECT" -a "$WAIT" = "0" ] && WAIT=""
fi
if [ -n "$BETWEEN" ]; then
 [ -z "$WAIT" ] && usage
 isinteger "$BETWEEN" || usage
fi

if [ -n "$DIRECT" ]; then
 CMDS="$DIRECT"
 DIRECT="yes"
 NOAUTO="yes"
 NOBUTTONS="yes"
elif [ -n "$ONBOOT" ]; then
 CMDS="$ONBOOT"
 ONBOOT="yes"
fi

if [ -n "$CMDS" ]; then
 # no upload or create for groups/rooms
 case "$CMDS" in *upload*|*create*) [ -z "$IP" ] && usage ;; esac

 # provide secrets for upload
 case "$CMDS" in *upload*) SECRETS=/etc/rsyncd.secrets ;; esac
fi


# common functions
# test if linbo-client is online
is_online(){
 $SSH -o ConnectTimeout=1 "$1" /bin/ls /start.conf &> /dev/null && return 0
 return 1
}

# waiting routine
do_wait(){
 local type="$1"
 local msg
 if [ "$type" = "wol" ]; then
  msg="Waiting $WAIT second(s) for client(s) to boot"
  secs="$WAIT"
  echo
 elif [ "$type" = "between" ]; then
  msg="  "
  secs="$BETWEEN"
 fi
 [ -z "$secs" -o "$secs" = "0" ] && return
 local c=0
 echo -n "$msg "
 while [ $c -lt $secs ]; do
  sleep 1
  echo -n "."
  c=$(( $c + 1 ))
 done
 echo
}

# print onboot linbocmd filename
onbootcmdfile(){
 echo "$LINBODIR/linbocmd/$1.cmd"
}


## evaluate commands string - begin
# strip from beginning of commands string
strip_cmds(){
 local tostrip="$1"
 CMDS="$(echo "$CMDS" | sed -e "s|^$tostrip||")"
}

# extract number parameter
extract_nr(){
 local nr="$(echo "$CMDS" | awk -F\: '{ print $2 }' | awk -F\, '{ print $1 }')"
 isinteger "$nr" || usage
 strip_cmds ":$nr"
 command[$c]="$cmd:$nr"
}

# extract comment
extract_comment(){
 local comment="$(echo "$CMDS" | awk -F\: '{ print $2 }')"
 # count commas in comment string
 local nrofc="$(echo "$CMDS" | grep -o "," | wc -l)"
 # if more than zero commas exist
 if [ $nrofc -gt 0 ]; then
  # strip next command
  local i
  for i in $KNOWNCMDS; do
   stringinstring ",$i" "$comment" && comment="$(echo "$comment" | sed -e "s|\,${i}.*||")"
  done
 fi
 strip_cmds ":$comment"
 command[$c]="${command[$c]}:\\\"$comment\\\""
}

# iterate over command string and split the commands
c=0
while [ -n "$CMDS" ]; do

 # extract command from string
 cmd="$(echo "$CMDS" | awk -F\: '{ print $1 }' | awk -F\, '{ print $1 }')"
 # check if command is known
 stringinstring "$cmd" "$KNOWNCMDS" || usage
 # build array of commands
 command[$c]="$cmd"
 # strip command from beginning of string
 strip_cmds "$cmd"

 # evaluate commands and parameters
 case "$cmd" in

  format)
   [ "${CMDS:0:1}" = ":" ] && extract_nr
  ;;

  sync|start|upload_cloop|upload_rsync)
   [ "${CMDS:0:1}" = ":" ] || usage
   extract_nr
  ;;

  initcache)
   if [ "${CMDS:0:1}" = ":" ]; then
    dltype="$(echo "$CMDS" | awk -F\: '{ print $2 }' | awk -F\, '{ print $1 }')"
    stringinstring "$dltype" "$DLTYPES" || usage
    strip_cmds ":$dltype"
    command[$c]="$cmd:$dltype"
   fi
  ;;

  create_cloop|create_rsync)
   extract_nr
   [ "${CMDS:0:1}" = ":" ] && extract_comment
  ;;

  label|partition|reboot|halt) ;;

  *)
   echo "Unknown command: $cmd."
   usage
  ;;

 esac

 # remove preceding comma
 strip_cmds ","
 c=$(( $c + 1 ))

done
NR_OF_CMDS=$c
## evaluate commands string - end


# evaluate ip / group / room
if [ -n "$IP" ]; then
 # get ip if hostname was given
 if ! validip "$IP"; then
  get_ip "$IP"
  [ -z "$RET" ] && usage
  IP="$RET"
 fi
 # test for pxe flag
 pxe="$(grep -i ^[a-z0-9] $WIMPORTDATA | grep -w "$IP" | awk -F\; '{ print $11 }')"
 [ "$pxe" = "0" ] && usage

elif [ -n "$GROUP" ]; then # hosts in group with pxe flag set
 IP="$(grep -i ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $3, $5, $11 }' | grep ^"$GROUP " | grep -v " 0" | awk '{ print $2 }')"
 [ -z "$IP" ] && usage

else # hosts in room with pxe flag set
 IP="$(grep -i ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $1, $5, $11 }' | grep ^"$ROOM " | grep -v " 0"  | awk '{ print $2 }')"
 [ -z "$IP" ] && usage
fi


# script header info
echo "###"
echo "### linbo-remote ($$) start: $(date)"
echo "###"


# create onboot command string, if -p is given
if [ -n "$ONBOOT" ]; then

 # add upload secrets
 [ -n "$SECRETS" ] && onbootcmds="$(grep ^linbo: "$SECRETS")"

 # collect commands
 c=0
 while [ $c -lt $NR_OF_CMDS ]; do
  if [ -n "$onbootcmds" ]; then
   onbootcmds="${onbootcmds},${command[$c]}"
  else
   onbootcmds="${command[$c]}"
  fi
  c=$(( $c + 1 ))
 done

 # add noauto and nobutton triggers
 [ -n "$NOAUTO" ] && onbootcmds="$onbootcmds noauto"
 [ -n "$NOBUTTONS" ] && onbootcmds="$onbootcmds nobuttons"

fi # onboot command string


# create linbocmd files for onboot tasks, if -p or -w is given
if [ -n "$ONBOOT" ] || [ -n "$WAIT" -a -n "$DIRECT" ]; then

 echo
 echo "Preparing onboot linbo tasks:"
 for i in $IP; do
  echo -n " $i ... "
  [ -n "$DIRECT" ] && echo "noauto nobuttons" > "$(onbootcmdfile "$i")"
  [ -n "$ONBOOT" ] && echo "$onbootcmds" > "$(onbootcmdfile "$i")"
  echo "Done."
 done

 chown nobody:root $LINBODIR/linbocmd/*
 chmod 660 $LINBODIR/linbocmd/*

fi


# wake-on-lan, if -w is given
if [ -n "$WAIT" ]; then
 echo
 echo "Trying to wake up:"
 c=0
 for i in $IP; do
  [ -n "$BETWEEN" -a "$c" != "0" ] && do_wait between
  echo -n " $i ... "
  # get mac address of client, stored in $RET
  get_mac "$i"
  [ -n "$DIRECT" ] && $WOL "$RET"
  if [ -n "$ONBOOT" ]; then
   # reboot linbo-clients which are already online
   if is_online "$i"; then
    echo "Client is already online, rebooting ..."
    $SSH "$i" reboot &> /dev/null
   else
    $WOL "$RET"
   fi
  fi
  [ -z "$DIRECT" -a -z "$ONBOOT" ] && $WOL "$RET"
  c=$(( $c + 1 ))
 done
fi


# send commands directly per linbo-ssh, with -c
send_cmds(){

 # wait for clients to come up
 [ -n "$WAIT" ] && do_wait wol

 echo
 echo "Sending command(s) to:"
 for i in $IP; do
  echo -n " $i ... "

  # look for not fetched onboot file and delete it
  [ -e "$(onbootcmdfile "$i")" ] && rm -f "$(onbootcmdfile "$i")"

  # test if client is online
  if ! is_online "$i"; then
   echo "Not online, host skipped."
   continue
  fi

  # provide secrets for image upload
  if [ -n "$SECRETS" ]; then
   echo -n "Uploading secrets ... "
   $SCP $SECRETS ${i}:/tmp
  fi

  # create a temporary script with linbo remote commands
  get_hostname "$i"
  HOSTNAME="$RET"
  REMOTESCRIPT=$TMPDIR/$$.$HOSTNAME.sh
  echo "#!/bin/sh" > $REMOTESCRIPT
  local c=0
  while [ $c -lt $NR_OF_CMDS ]; do
   # pause between commands
   [ $c -gt 0 ] && echo "sleep 3" >> $REMOTESCRIPT
   case ${command[$c]} in
    start*|reboot|halt|poweroff)
     START=yes
     echo "$SSH $i $WRAPPER ${command[$c]} &" >> $REMOTESCRIPT
     echo "sleep 10" >> $REMOTESCRIPT ;;
    *) echo "$SSH $i $WRAPPER ${command[$c]}" >> $REMOTESCRIPT ;;
   esac
   c=$(( $c + 1 ))
  done
  [ -n "$SECRETS" -a -z "$START" ] && echo "$SSH $i /bin/rm /tmp/rsyncd.secrets" >> $REMOTESCRIPT
  echo "rm $REMOTESCRIPT" >> $REMOTESCRIPT
  echo "exit 0" >> $REMOTESCRIPT
  chmod 755 $REMOTESCRIPT

  # start script in screen session
  screen -dmS $HOSTNAME.linbo-remote $REMOTESCRIPT

  echo "Ok!"
 done
}


# test if waked up clients have done their onboot tasks, with -p
test_onboot(){

 # wait for clients to come up
 do_wait wol

 # verifying if clients have done their onboot tasks
 echo
 echo "Verifying onboot tasks:"
 for i in $IP; do
  echo -n " $i ... "
  if [ -e "$(onbootcmdfile "$i")" ]; then
   rm -f "$(onbootcmdfile "$i")"
   echo "Not done, host skipped!"
  else
   echo "Ok!"
  fi
 done
}


# test if waked up clienst are online
test_online(){

 # wait for clients to come up
 do_wait wol

 # testing if clients are online
 echo
 echo "Testing if clients have booted:"
 for i in $IP; do
  echo -n " $i ... "
  if is_online "$i"; then
   echo "Online!"
  else
   echo "Not online!"
  fi
 done
}


# send commands live (-c)
[ -n "$DIRECT" ] && send_cmds

# test onboot tasks (-p)
[ -n "$ONBOOT" -a -n "$WAIT" -a "$WAIT" != "0" ] && test_onboot

# test online (-w only)
[ -z "$ONBOOT" -a -z "$DIRECT" -a -n "$WAIT" -a "$WAIT" != "0" ] && test_online


# script footer info
echo
echo "###"
echo "### linbo-remote ($$) end: $(date)"
echo "###"

exit 0
