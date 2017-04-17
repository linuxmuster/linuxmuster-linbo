#!/bin/bash
#
# Pre-Download script for rsync/LINBO
# thomas@linuxmuster.net
# 20170218
#

# read in linuxmuster specific environment
source /etc/linbo/linbo.conf || exit 1
source $ENVDEFAULTS || exit 1
source $HELPERFUNCTIONS || exit 1
[ "$FLAVOUR" = "lmn6" ] && source "$LINBOSHAREDIR/lmn6helperfunctions.sh"
[ -n "$LINBODIR" ] || LINBOLOGDIR="/var/log"
[ -n "$LINBOLOGDIR" ] || LINBOLOGDIR="$LINBODIR/log"
LOGFILE="$LINBOLOGDIR/rsync-pre-download.log"

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync pre download begin: $(date) ###"

FILE="${RSYNC_MODULE_PATH}/${RSYNC_REQUEST##$RSYNC_MODULE_NAME/}"
EXT="$(echo $RSYNC_REQUEST | grep -o '\.[^.]*$')"
PIDFILE="/tmp/rsync.$RSYNC_PID"
echo "$FILE" > "$PIDFILE"

compname="$(get_compname_from_rsync $RSYNC_HOST_NAME)"

# recognize upload of windows activation tokens
stringinstring "winact.tar.gz.upload" "$FILE" && EXT="winact-upload"

# recognize download request of local grub.cfg
stringinstring ".grub.cfg" "$FILE" && EXT="grub-local"

if [ "$FLAVOUR" = "oss" ]; then
  # recognize download request of start.conf-ip
  [[ ${FILE##$RSYNC_MODULE_PATH/} =~ start\.conf-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] && EXT="start.conf.gruppe"
fi

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "RSYNC_REQUEST: $RSYNC_REQUEST"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "EXT: $EXT"

case $EXT in

 # handle machine account password
 *.macct)
  upload_password_to_ldap $compname ${RSYNC_REQUEST##*/}
 ;;

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

 # provide host's opsi key for download
 *.opsikey)
  # invoked by linbo_cmd on postsync
  # if opsi server is configured and host is opsimanaged
  if ([ -n "$opsiip" ] && opsimanaged "$compname"); then
   echo "Opsi key file $(basename $FILE) requested."
   key="$(grep ^"$RSYNC_HOST_NAME" "$LINBOOPSIKEYS" | awk -F\: '{ print $2 }')"
   if [ -n "$key" ]; then
    echo "Opsi key for $RSYNC_HOST_NAME found, providing key file."
    echo "$key" > "$FILE"
    chmod 644 "$FILE"
   fi
  fi
 ;;

 # handle windows product key request
 *.winkey)
  # get key from workstations and write it to temporary file
  if [ -n "$compname" ]; then
   winkey="$(get_win_key $compname)"
   officekey="$(get_office_key $compname)"
   [ -n "$winkey" ] && echo "winkey=$winkey" > "$FILE"
   [ -n "$officekey" ] && echo "officekey=$officekey" >> "$FILE"
  fi
 ;;

 # handle windows activation tokens archive
 winact-upload)
  RC=0
  FILE="${FILE%.upload}"
  # fetch archive from client
  echo "Upload request for windows activation tokens archive."
  linbo-scp "${RSYNC_HOST_NAME}:/cache/$(basename $FILE)" "${FILE}.tmp" || RC="1"
  # if archive file already exists try to merge old and new archives
  if [ -s "$FILE" -a "$RC" = "0" ]; then
   echo "Updating existing archive $FILE."
   tmpdir="/var/tmp/winact-upload.$$"
   curdir="$(pwd)"
   mkdir -p "$tmpdir"
   # extract old archive to tmpdir
   tar xf "$FILE" -C "$tmpdir" || RC="1"
   if [ "$RC" = "0" ]; then
    # extract uploaded archive over old archive in tmpdir
    tar xf "${FILE}.tmp" -C "$tmpdir" || RC="1"
   fi
   if [ "$RC" = "0" ]; then
    rm -f "${FILE}.tmp"
    cd "$tmpdir"
    # pack content of tmpdir to temporary archive
    tar czf "${FILE}.tmp" * || RC="1"
    cd "$curdir"
   fi
   rm -rf "$tmpdir"
  fi
  # move uploaded file in place
  if [ "$RC" = "0" ]; then
   rm -f "$FILE"
   mv "${FILE}.tmp" "$FILE" || RC="1"
  fi
  if [ "$RC" = "0" ]; then
   echo "Upload of $FILE successfully finished."
  else
   echo "Sorry. Upload of $FILE failed."
  fi
  rm -f "$PIDFILE"
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
  if [ "$FLAVOUR" = "oss" ]; then
    group="$(get_hwconf_group $compname)"
    echo "Gruppe: $group create link to $FILE"
    [[ -n $group ]] && ln -sf "$LINBODIR/start.conf.$group" "$FILE"
  fi
 ;;

 *) ;;

esac

echo "RC: $RSYNC_EXIT_STATUS"
echo "### rsync pre download end: $(date) ###"

exit $RSYNC_EXIT_STATUS
