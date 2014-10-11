#!/bin/bash
#
# exec linbo commands remote per ssh
#
# thomas@linuxmuster.net
# 11.10.2014
# GPL V3
#

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

KNOWNCMDS="partition format initcache sync start create_cloop create_rsync upload_cloop upload_rsync reboot halt"
DLTYPES="multicast rsync torrent"
SSH=linbo-ssh
SCP=linbo-scp
WRAPPER=/usr/bin/linbo_wrapper
ETHERWAKE="$(which etherwake)"
TMPDIR=/var/tmp
PXETPL="$LINBOTPLDIR/linbo-remote.pxe"

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
 echo "                    per ssh to the client(s)."
 echo " -d                 Disables start, sync and new buttons on next boot."
 echo "                    To be used together with option -p."
 echo " -g <group>         All hosts of this hostgroup will be processed."
 echo " -i <ip|hostname>   Ip or hostname of client to be processed."
 echo " -l                 List current linbo-remote screens."
 echo " -n                 Bypasses a start.conf configured autostart on next boot."
 echo "                    To be used together with option -p."
 echo " -r <room>          All hosts of this room will be processed."
 echo " -p <cmd1,cmd2,...> Pipe the command list into a one time pxeboot configfile"
 echo "                    executed automatically next time the client boots."
 echo " -w <sec>           Send wake-on-lan magic packets to the client(s)"
 echo "                    and wait <sec> seconds before executing the"
 echo "                    commands given with \"-c\" or in case of \"-p\" after"
 echo "                    the creation of the pxe boot files."
 echo
 echo "Important: * Options \"-r\", \"-g\" and \"-i\" exclude each other, \"-c\" and"
 echo "             \"-p\" as well."
 echo "           * Option \"-c\" together with \"-w\" bypasses autostart and disables"
 echo "             start, sync and new buttons on next boot automatically."
 echo
 echo "Supported commands for -c or -p options are:"
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
 echo "The commands were sent per ssh to the linbo_wrapper on the client and processed"
 echo "in the order given on the commandline."
 echo "create_* and upload_* commands cannot be used with -r and -g options."
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
while getopts ":b:c:dg:hi:lnp:r:w:" opt; do

echo "### opt: $opt $OPTARG"

 case $opt in
  l) list
     exit 0 ;;
  b) BETWEEN=$OPTARG ;;
  c) DIRECT=$OPTARG ;;
  d) NOBUTTONS=yes ;;
  i) IP=$OPTARG ;;
  g) GROUP=$OPTARG ;;
  p) PIPE=$OPTARG  ;;
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
[ -n "$DIRECT" -a -n "$PIPE" ] && usage
[ -z "$DIRECT" -a -z "$PIPE" -a -z "$WAIT" ] && usage
if [ -n "$WAIT" ]; then
 [ -z "$DIRECT" -a -z "$PIPE" ] && usage
 if [ ! -x "$ETHERWAKE" ]; then
  echo "$ETHERWAKE not found!"
  exit 1
 fi
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
elif [ -n "$PIPE" ]; then
 CMDS="$PIPE"
 PIPE="yes"
fi


if [ -n "$CMDS" ]; then
 # no upload or create for groups/rooms
 case "$CMDS" in *upload*|*create*) [ -z "$IP" ] && usage ;; esac

 # provide secrets for upload
 case "$CMDS" in *upload*) SECRETS=/etc/rsyncd.secrets ;; esac
fi


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

  partition|reboot|halt) ;;

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
 # filter out host with pxe flag
 for i in $IP; do
  pxe="$(grep ^[a-z0-9] $WIMPORTDATA | grep -w "$i" | awk -F\; '{ print $11 }')"
  [ "$pxe" = "0" ] && IP="${IP/$i/}"
 done
 strip_spaces "$IP"
 [ -z "$RET" ] && usage
elif [ -n "$GROUP" ]; then # hosts in group with pxe flag set
 IP="$(grep ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $3, $5, $11 }' | grep ^"$GROUP " | grep -v " 0" | awk '{ print $2 }')"
 [ -z "$IP" ] && usage
else # hosts in room with pxe flag set
 IP="$(grep ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $1, $5, $11 }' | grep ^"$ROOM " | grep -v " 0"  | awk '{ print $2 }')"
 [ -z "$IP" ] && usage
fi

# script header info
echo "###"
echo "### linbo-remote ($$) start: $(date)"
echo "###"

# compute pipename from mac address
pxepipename(){
 local ip="$1"
 get_mac "$ip"
 local mac="${RET:0:17}"
 [ -z "$mac" ] && return
 local pipe="01-${mac//:/-}"
 echo "$pipe" | tr A-Z a-z
}

# write pipe which will function as a one time pxelinux config file
write_pipe(){
 local pxefile="$PXECFGDIR/$1"
 local linbocmd="$2"
 [ -n "$NOAUTO" ] && linbocmd="$linbocmd autostart=0"
 [ -n "$NOBUTTONS" ] && linbocmd="$linbocmd nobuttons"
 local kopts="$3"
 if [ -e "$pxefile" ]; then
  cat "$pxefile" &> /dev/null
  [ -e "$pxefile" ] && rm -rf "$pxefile"
 fi
 mkfifo "$pxefile"
 sed -e "s|@@kopts@@|$kopts|
         s|@@linbocmd@@|$linbocmd|" "$PXETPL" > "$pxefile" && rm "$pxefile" &
}

# wake-on-lan stuff
if [ -n "$WAIT" ]; then
 # check interface (yannik's pull request to take only first default route)
 iface="$(route | grep ^default | awk '{ print $8 }'  | head -1)"
 if [ -z "$iface" ]; then
  echo "Default route not found. Cannot determine network interface!"
  exit 1
 fi
 # wake-on-lan
 echo "Trying to wake up:"
 for i in $IP; do
  echo " $i ..."
  # one time pxe config file
  otpxefile="$(pxepipename $i)"
  # collect all filenames and ips in one var
  collection="$collection $otpxefile,$i"
  [ -n "$DIRECT" ] && write_pipe "$otpxefile" "" "$(linbo_kopts "$LINBODIR/start.conf-$i")"
  get_mac "$i"
  $ETHERWAKE -i "$iface" "$RET"
  [ -n "$BETWEEN" ] && sleep "$BETWEEN"
 done
 if [ -n "$DIRECT" ]; then
  # wait for clients to boot
  echo "Waiting $WAIT second(s) for client(s) to boot ..."
  sleep "$WAIT"
  # remove one time pxefiles of clients not waked up
  for i in $collection; do
   otpxefile="$(echo "$i" | sed -e 's|,.*$||')"
   ip="$(echo "$i" | sed -e 's|.*,||')"
   if [ -e "$PXECFGDIR/$otpxefile" ]; then
    cat "$PXECFGDIR/$otpxefile" &> /dev/null
    ips_not_waked_up="$ips_not_waked_up $ip"
   fi
  done
 fi
fi

# send commands directly per linbo-ssh
send_cmds(){
 echo "Sending command(s):"
 for i in $IP; do
  echo -n " $i ... "
  if echo "$ips_not_waked_up" | grep -qw "$i"; then
   echo "not booted, skipping."
   continue
  fi
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
   screen -dmS $HOSTNAME.linbo-remote $REMOTESCRIPT
   echo "Ok!"
  else
   echo "Failed!"
  fi
 done
}

# create pipes for all ips
create_pipes(){
 local cmdstr
 # provide linbo password for upload
 if [ -n "$SECRETS" ]; then
  local pass="$(grep ^linbo "$SECRETS")"
  echo $pass | grep -q "linbo:" && cmdstr="${pass},"
 fi
 # create command string
 local c=0
 while [ $c -lt $NR_OF_CMDS ]; do
  if [ -n "$cmdstr" ]; then
   cmdstr="${cmdstr},${command[$c]}"
  else
   cmdstr="${command[$c]}"
  fi
  c=$(( $c + 1 ))
 done
 # iterate over ips, get kernel options from start.conf and write pipe
 local conf=""
 local pxefile
 echo "Writing pxe boot files:"
 for i in $IP; do
  echo -n " $i ... "
  conf="$LINBODIR/start.conf-$i"
  if [ ! -e "$conf" ]; then
   echo "skipped, no start.conf found!"
   continue
  fi
  # read kernel options
  kopts="$(linbo_kopts "$conf")"
  # get pxe filename
  pxefile="$(pxepipename "$i")"
  if [ -z "$pxefile" ]; then
   echo "skipped, no mac address found!"
   continue
  fi
  write_pipe "$pxefile" "$cmdstr" "$kopts"
  echo "Done!"
 done
 # test for not waked up clients and remove one time pxe files
 if [ -n "$WAIT" -a $WAIT -gt 0 ]; then
  echo "Waiting $WAIT second(s) for client(s) to boot ..."
  sleep "$WAIT"
  # remove one time pxefiles of clients not waked up
  echo "Looking for booted clients:"
  for i in $collection; do
   ip="$(echo "$i" | sed -e 's|.*,||')"
   echo -n " $ip ... "
   otpxefile="$(echo "$i" | sed -e 's|,.*$||')"
   if [ -e "$PXECFGDIR/$otpxefile" ]; then
    echo "not booted, removing pxe file!"
    cat "$PXECFGDIR/$otpxefile" &> /dev/null
   else
    echo "Ok!"
   fi
  done
 elif [ -n "$WAIT" -a $WAIT -eq 0 ]; then
  echo "Skipping test for booted clients."
 fi
}


if [ -n "$DIRECT" ]; then
 send_cmds
elif [ -n "$PIPE" ]; then
 create_pipes
fi


# script footer info
echo "###"
echo "### linbo-remote ($$) end: $(date)"
echo "###"

exit 0
