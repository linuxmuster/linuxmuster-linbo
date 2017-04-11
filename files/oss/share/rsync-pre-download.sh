#!/bin/bash
#
# Pre-Download script for rsync/LINBO
# thomas@linuxmuster.net
# 08.03.2016
#

# read in oss-linbo specific environment
. /usr/share/linbo/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1
. /usr/share/linbo/helperfunctions.sh || exit 1

LOGFILE="$LINBOLOGDIR/rsync-pre-download.log"

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync pre download begin: $(date) ###"

FILE="${RSYNC_MODULE_PATH}/${RSYNC_REQUEST##$RSYNC_MODULE_NAME/}"
EXT="$(echo $RSYNC_REQUEST | grep -o '\.[^.]*$')"
PIDFILE="/tmp/rsync.$RSYNC_PID"
echo "$FILE" > "$PIDFILE"

compname="$(echo $RSYNC_HOST_NAME | awk -F\. '{ print $1 }')"

# recognize download request of local grub.cfg
stringinstring ".grub.cfg" "$FILE" && EXT="grub-local"

# recognize download request of start.conf-ip
[[ ${FILE##$RSYNC_MODULE_PATH/} =~ start\.conf-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] && EXT="start.conf.gruppe"

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "RSYNC_REQUEST: $RSYNC_REQUEST"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "EXT: $EXT"

case $EXT in

 # fetch logfiles from client
 *.log)
  host_logfile="$(basename "$FILE")"
  echo "Upload request for $host_logfile."
  src_logfile="$(echo "$FILE" | sed -e "s|$LINBODIR/tmp/${compname}_|/tmp/|")"
  tgt_logfile="$LINBOLOGDIR/$host_logfile"
  linbo-scp -v "${RSYNC_HOST_NAME}:$src_logfile" "$FILE" || RC="1"
  if [ -s "$FILE" ]; then
   echo "## Log session begin: $(date) ##" >> "$tgt_logfile"
   cat "$FILE" >> "$tgt_logfile"
   echo "## Log session end: $(date) ##" >> "$tgt_logfile"
  fi
  rm -f "$FILE"
  touch "$FILE"
 ;;

 # prepare download of local grub.cfg
 grub-local)
  grubcfg_tpl="$LINBOTPLDIR/grub.cfg.local"
  group="$(basename "$FILE" | awk -F\. '{ print $2 }')"
  startconf="$LINBODIR/start.conf.$group"
  append="$(linbo_kopts "$startconf") localboot"
  sed -e "s|linux \$linbo_kernel .*|linux \$linbo_kernel $append|g" "$grubcfg_tpl" > "$FILE"
 ;;

 # create download link start.conf-ip
 start.conf.gruppe)
  group="$(get_hwconf_group $compname)"
  echo "Gruppe: $group create link to $FILE"
  [[ -n $group ]] && ln -sf "$LINBODIR/start.conf.$group" "$FILE"
 ;;

 *) ;;

esac

echo "RC: $RSYNC_EXIT_STATUS"
echo "### rsync pre download end: $(date) ###"

exit $RSYNC_EXIT_STATUS
