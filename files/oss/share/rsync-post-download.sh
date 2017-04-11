#!/bin/bash
#
# Post-Download script for rsync/LINBO
# thomas@linuxmuster.net
# 08.03.2016
#

# read in paedml specific environment
. /usr/share/oss-linbo/config/dist.conf || exit 1
. /etc/sysconfig/schoolserver || exit 1
. $HELPERFUNCTIONS || exit 1

LOGFILE="$LINBOLOGDIR/rsync-post-download.log"

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync post download begin: $(date) ###"

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

PIDFILE="/tmp/rsync.$RSYNC_PID"

# Check for pidfile, exit if nothing to do
[ -s "$PIDFILE" ] || exit 0

# read file created by pre-upload script
FILE="$(<$PIDFILE)"
EXT="$(echo $FILE | grep -o '\.[^.]*$')"

pcname="$(echo $RSYNC_HOST_NAME | awk -F \. '{ print $1 }')"

# handle request for obsolete menu.lst
if stringinstring "menu.lst." "$FILE"; then
 GROUP="${EXT/./}"
 CACHE="$(grep -i ^cache "$LINBODIR/start.conf.$GROUP" | awk -F\= '{ print $2 }' | awk '{ print $1 }' | tail -1)"
 [ -n "$CACHE" ] && EXT="upgrade"
fi

# recognize download request of local grub.cfg
stringinstring ".grub.cfg" "$FILE" && EXT="grub-local"

# recognize download request of start.conf-ip
[[ ${FILE##$RSYNC_MODULE_PATH/} =~ start\.conf-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] && EXT="start.conf.gruppe"

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "EXT: $EXT"

case $EXT in

 # remove linbocmd file after download
 *.cmd)
  echo "Removing onboot linbocmd file $FILE."
  rm -f "$FILE"
 ;;

 # remove dummy logfile after download
 *.log)
  echo "Removing dummy logfile $FILE."
  rm -f "$FILE"
 ;;

 *.gz)
  # repair old linbofs filename
  if [ "$(basename "$FILE")" = "linbofs.gz" ]; then
   linbo-scp "$LINBODIR/linbofs.lz" "${RSYNC_HOST_NAME}:/cache"
   linbo-ssh "$RSYNC_HOST_NAME" /bin/rm /cache/linbofs.gz /cache/linbo*.info
  fi
  # repair old linbofs64 filename
  if [ "$(basename "$FILE")" = "linbofs64.gz" ]; then
   linbo-scp "$LINBODIR/linbofs64.lz" "${RSYNC_HOST_NAME}:/cache"
   linbo-ssh "$RSYNC_HOST_NAME" /bin/rm /cache/linbofs64.gz /cache/linbo64*.info
  fi
 ;;
 
 # handle server based grub reboot in case of remote cache
 *.reboot)
  # get reboot parameters from filename
  rebootstr="$(echo "$FILE" | sed -e "s|^$LINBODIR/||")"
  bootpart="$(echo "$rebootstr" | awk -F\# '{ print $1 }' )"
  kernel="$(echo "$rebootstr" | awk -F\# '{ print $2 }' )"
  initrd="$(echo "$rebootstr" | awk -F\# '{ print $3 }' )"
  append="$(echo "$rebootstr" | awk -F\# '{ print $4 }' )"
  # grubenv template
  grubenv_tpl="$LINBOTPLDIR/grubenv.reboot"
  # create fifo socket
  fifo="$LINBODIR/boot/grub/spool/${pcname}.reboot"
  rm -f "$fifo"
  mkfifo "$fifo"
  # create screen session
  screen -dmS "${pcname}.reboot" "$LINBOSHAREDIR/reboot_pipe.sh" "$bootpart" "$kernel" "$initrd" "$append" "$grubenv_tpl" "$fifo"
 ;;

 upgrade)
  # update old 2.2 clients
  LINBOFSCACHE="/var/cache/oss-linbo/linbofs"
  linbo-ssh "$RSYNC_HOST_NAME" 'echo -e "#!/bin/sh\necho \"Processing LINBO upgrade ... waiting for reboot ...\"\nsleep 120\n/sbin/reboot" > /linbo.sh'
  linbo-ssh "$RSYNC_HOST_NAME" chmod +x /linbo.sh
  linbo-scp --exclude start.conf --exclude linbo.sh -a "$LINBOFSCACHE/" "${RSYNC_HOST_NAME}:/"
  for i in linbo64 linbofs64.lz; do
   linbo-scp "$LINBODIR/$i" "${RSYNC_HOST_NAME}:/cache"
  done
  linbo-ssh "$RSYNC_HOST_NAME" /usr/bin/linbo_cmd update "$SCHOOL_SERVER" "$CACHE"
 ;;

 grub-local)
  if [ -e "$FILE" ]; then
   echo "Removing $FILE."
   rm -f "$FILE"
  fi
 ;;

 # remove download link start.conf-ip
 start.conf.gruppe)
  echo "remove link to $FILE"
  [[ -L $FILE ]] && rm -f "$FILE"
 ;;

 *) ;;

esac

rm -f "$PIDFILE"
