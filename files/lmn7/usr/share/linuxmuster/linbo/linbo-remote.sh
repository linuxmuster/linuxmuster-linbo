#!/bin/bash
#
# exec linbo commands remote per ssh
#
# thomas@linuxmuster.net
# 20210430
# GPL V3
#

# read linuxmuster environment
source /usr/share/linuxmuster/defaults.sh || exit 1
source $LINBOSHAREDIR/helperfunctions.sh || exit 1

KNOWNCMDS="label partition format initcache sync start create_cloop create_rsync upload_cloop upload_rsync reboot halt"
DLTYPES="multicast rsync torrent"
SSH="/usr/sbin/linbo-ssh -o BatchMode=yes -o StrictHostKeyChecking=no"
SCP=/usr/sbin/linbo-scp
WRAPPER=/usr/bin/linbo_wrapper
WOL="$(which wakeonlan)"
TMPDIR=/var/tmp

# usage info
usage(){
  msg="$1"
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
  echo " -d                 Disables gui. To be used only together with option -c."
  echo "                    When used together with -n the GUI will be disabled immidiately after boot."
  echo " -g <group>         All hosts of this hostgroup will be processed."
  echo " -i <i1,i2,...>     Single ip or hostname or comma separated list of ips"
  echo "                    or hostnames of clients to be processed."
  echo " -l                 List current linbo-remote screens."
  echo " -n                 Bypasses start.conf configured auto functions"
  echo "                    (partition, format, initcache, start) on next boot."
  echo "                    To be used only together with options -p"
  echo "                    or -c in conjunction with -w."
  echo " -r <room>          All hosts of this room will be processed."
  echo " -p <cmd1,cmd2,...> Create an onboot command file executed automatically"
  echo "                    once next time the client boots."
  echo " -w <sec>           Send wake-on-lan magic packets to the client(s)"
  echo "                    and wait <sec> seconds before executing the"
  echo "                    commands given with \"-c\" or in case of \"-p\" after"
  echo "                    the creation of the pxe boot files."
  echo " -u                 Use broadcast address with wol."
  echo
  echo "Important: * Options \"-r\", \"-g\" and \"-i\" exclude each other, \"-c\" and"
  echo "             \"-p\" as well."
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
  echo "create_* and upload_* commands cannot be used with hostlists, -r and -g options."
  if [ -n "$msg" ]; then
    echo
    echo "$msg"
  fi
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
while getopts ":b:c:dg:hi:lnp:r:uw:" opt; do

  # debug
  #echo "### opt: $opt $OPTARG"

  case $opt in
    l) list
      exit 0 ;;
    b) BETWEEN=$OPTARG ;;
    c) DIRECT=$OPTARG ;;
    d) DISABLEGUI=yes ;;
    i)
      # create a list of hosts
      for i in ${OPTARG//,/ }; do
        if validhostname "$i"; then
          HOSTNAME="$i"
        else
          validip "$i" && IP="$i"
          HOSTNAME=""
        fi
        [ -n "$IP" ] && HOSTNAME="$(nslookup "$IP" 2> /dev/null | head -1 | awk '{ print $4 }' | awk -F\. '{ print $1 }')"
        if [ -n "$HOSTNAME" ]; then
          # check for pxe flag, only use linbo related pxe flags 1 & 2
          pxe="$(grep -i ^[a-z0-9] $WIMPORTDATA | grep ";$HOSTNAME;" | awk -F\; '{ print $11 }')"
          if [ "$pxe" != "1" -a "$pxe" != "2" ]; then
            echo "Skipping $i, not a pxe host!"
            continue
          fi
          if [ -n "$HOSTS" ]; then
            HOSTS="$HOSTS $HOSTNAME"
          else
            HOSTS="$HOSTNAME"
          fi
        else
          echo "Host $i not found!"
        fi
      done
      [ -z "$HOSTS" ] && usage "No valid hosts in list!"
      ;;
    g) GROUP=$OPTARG ;;
    p) ONBOOT=$OPTARG  ;;
    r) ROOM=$OPTARG ;;
    u) USEBCADDR=yes ;;
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
[ -z "$GROUP" -a -z "$HOSTS" -a -z "$ROOM" ] && usage "No hosts, no group, no room defined!"
[ -n "$GROUP" -a -n "$HOSTS" ] && usage "Group and hosts defined!"
[ -n "$GROUP" -a -n "$ROOM" ] && usage "Group and room defined!"
[ -n "$DIRECT" -a -n "$ONBOOT" ] && usage "Direct and onboot commands defined!"
[ -z "$DIRECT" -a -z "$ONBOOT" -a -z "$WAIT" ] && usage "No commands or wakeonlan defined!"
if [ -n "$WAIT" ]; then
  if [ ! -x "$WOL" ]; then
    echo "$WOL not found!"
    exit 1
  fi
  [ -n "$DIRECT" -a "$WAIT" = "0" ] && WAIT=""
fi
if [ -n "$BETWEEN" ]; then
  [ -z "$WAIT" ] && usage "Option -b can only be used with -w!"
  isinteger "$BETWEEN" || usage "$BETWEEN is not an integer variable!"
fi

if [ -n "$NOAUTO" -a -z "$ONBOOT" ]; then
  [ -n "$DIRECT" -a -n "$WAIT" ] || usage "Option -n can only be used with -p or with -c and -w together!"
fi

[ -n "$DISABLEGUI" -a -z "$DIRECT" ] && usage "Option -d can only be used with -c!"

if [ -n "$DIRECT" ]; then
  CMDS="$DIRECT"
  DIRECT="yes"
elif [ -n "$ONBOOT" ]; then
  CMDS="$ONBOOT"
  ONBOOT="yes"
fi

# no upload or create commands for list of hosts
if [ -n "$CMDS" ]; then
  pattern=" |'"
  [[ $HOSTS =~ $pattern ]] && LIST="yes"
  [ -n "$GROUP" -o -n "$ROOM" ] && LIST="yes"
  case "$CMDS" in *upload*|*create*) [ -n "$LIST" ] && usage "Upload or create cannot be used with lists!" ;; esac

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
  isinteger "$nr" || usage "$nr is not an integer variable!"
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
  stringinstring "$cmd" "$KNOWNCMDS" || usage "Command \"$cmd\" is not known!"
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
      [ "${CMDS:0:1}" = ":" ] || usage "Command string \"$CMDS\" is not valid!"
      extract_nr
      ;;

    initcache)
      if [ "${CMDS:0:1}" = ":" ]; then
        dltype="$(echo "$CMDS" | awk -F\: '{ print $2 }' | awk -F\, '{ print $1 }')"
        stringinstring "$dltype" "$DLTYPES" || usage "$dltype is not known!"
        strip_cmds ":$dltype"
        command[$c]="$cmd:$dltype"
      fi
      ;;

    create_cloop|create_rsync)
      extract_nr
      [ "${CMDS:0:1}" = ":" ] && extract_comment
      ;;

    label|partition|reboot|halt) ;;

    *) usage "Unknown command: $cmd!" ;;

  esac

  # remove preceding comma
  strip_cmds ","
  c=$(( $c + 1 ))

done
NR_OF_CMDS=$c
## evaluate commands string - end


# get ips of group or room if given on cl
if [ -n "$GROUP" ]; then # hosts in group with pxe flag set
  HOSTS="$(grep -i ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $3, $2, $11 }' | grep ^"$GROUP " | grep " [1-2]" | awk '{ print $2 }')"
  msg="group $GROUP"
elif [ -n "$ROOM" ]; then # hosts in room with pxe flag set
  HOSTS="$(grep -i ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $1, $2, $11 }' | grep ^"$ROOM " | grep " [1-2]" | awk '{ print $2 }')"
  msg="room $ROOM"
fi
[ -z "$HOSTS" ] && usage "No hosts in $msg!"


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

  # add noauto triggers
  [ -n "$NOAUTO" ] && onbootcmds="$onbootcmds noauto"

fi # onboot command string


# create linbocmd files for onboot tasks, if -p or -w is given
if [ -n "$ONBOOT" ] || [ -n "$WAIT" -a -n "$DIRECT" -a -n "$NOAUTO" ] || [ -n "$WAIT" -a -n "$DIRECT" -a -n "$DISABLEGUI" ]; then

  echo
  echo "Preparing onboot linbo tasks:"
  for i in $HOSTS; do
    echo -n " $i ... "

    if [ -n "$DIRECT" ]; then
      echo -n "" > "$(onbootcmdfile "$i")"
      [ -n "$NOAUTO" ] && echo -n " noauto " >> "$(onbootcmdfile "$i")"
      [ -n "$NOAUTO" -a -n "$DISABLEGUI" ] && echo -n " gui_ctl_disable " >> "$(onbootcmdfile "$i")"
    elif [ -n "$ONBOOT" ]; then
      echo "$onbootcmds" > "$(onbootcmdfile "$i")"
    fi

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
  for i in $HOSTS; do
    [ -n "$BETWEEN" -a "$c" != "0" ] && do_wait between
    echo -n " $i ... "
    # get mac address of client from devices.csv
    macaddr="$(get_mac "$i")"
    # use broadcast address
    if [ -n "$USEBCADDR" ]; then
      if validip "$i"; then
        hostip="$i"
      else
        hostip="$(get_ip "$i")"
      fi
      bcaddr=$(get_bcaddress "$hostip")
      [ -n "$bcaddr" ] && WOL="$WOL -i $bcaddr"
    fi

    [ -n "$DIRECT" ] && $WOL "$macaddr"
    if [ -n "$ONBOOT" ]; then
      # reboot linbo-clients which are already online
      if is_online "$i"; then
        echo "Client is already online, rebooting ..."
        $SSH "$i" reboot &> /dev/null
      else
        $WOL "$macaddr"
      fi
    fi
    [ -z "$DIRECT" -a -z "$ONBOOT" ] && $WOL "$macaddr"
    c=$(( $c + 1 ))
  done
fi


# send commands directly per linbo-ssh, with -c
send_cmds(){

  # wait for clients to come up
  [ -n "$WAIT" ] && do_wait wol

  echo
  echo "Sending command(s) to:"
  for i in $HOSTS; do
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
    HOSTNAME="$i"
    LOGFILE="$LINBOLOGDIR/$HOSTNAME.linbo-remote"
    REMOTESCRIPT=$TMPDIR/$$.$HOSTNAME.sh
    echo "#!/bin/bash" > $REMOTESCRIPT
    # Disable the gui only if the -n flag is not given, as in this case it is already disabled
    [ -n "$DISABLEGUI" -a -z "$NOAUTO" ] && echo "$SSH $i gui_ctl disable" >> $REMOTESCRIPT
    echo "RC=0" >> $REMOTESCRIPT
    local c=0
    while [ $c -lt $NR_OF_CMDS ]; do
      # pause between commands
      [ $c -gt 0 ] && echo "sleep 3" >> $REMOTESCRIPT
      case ${command[$c]} in
        start*|reboot|halt|poweroff)
          START=yes
          echo "[ \$RC = 0 ] && $SSH $i $WRAPPER ${command[$c]} &" >> $REMOTESCRIPT
          echo "sleep 10" >> $REMOTESCRIPT ;;
        *) echo "[ \$RC = 0 ] && $SSH $i $WRAPPER ${command[$c]} || RC=1" >> $REMOTESCRIPT ;;
      esac
      c=$(( $c + 1 ))
    done
    [ -n "$SECRETS" -a -z "$START" ] && echo "$SSH $i /bin/rm -f /tmp/rsyncd.secrets" >> $REMOTESCRIPT
    [ -n "$DISABLEGUI" ] && echo "$SSH $i gui_ctl restore" >> $REMOTESCRIPT
    echo "rm -f $REMOTESCRIPT" >> $REMOTESCRIPT
    echo "exit \$RC" >> $REMOTESCRIPT
    chmod 755 $REMOTESCRIPT

    # start script in screen session
    SCREENNAME="$HOSTNAME.linbo-remote"
    screen -L -Logfile "$LOGFILE" -dmS "$SCREENNAME" $REMOTESCRIPT
    PID="$(screen -ls | grep -w "$SCREENNAME" | awk '{print $1}' | awk -F. '{print $1}')"
    [ -z "$PID" ] && PID="unknown"
    echo "Started with PID $PID. Log see $LOGFILE."
  done
}


# test if waked up clients have done their onboot tasks, with -p
test_onboot(){

  # wait for clients to come up
  do_wait wol

  # verifying if clients have done their onboot tasks
  echo
  echo "Verifying onboot tasks:"
  for i in $HOSTS; do
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
  for i in $HOSTS; do
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
