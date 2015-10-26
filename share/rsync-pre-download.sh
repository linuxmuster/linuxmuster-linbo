#!/bin/bash
#
# Pre-Download script for rsync/LINBO
# thomas@linuxmuster.net
# 26.10.2015
#

# read in linuxmuster.net specific environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

LOGFILE=rsync-pre-download.log
if [ -n "$LINBODIR" ]; then
 LOGFILE="$LINBODIR/log/$LOGFILE"
else
 LOGFILE="/var/log/$LOGFILE"
fi

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync pre download begin: $(date) ###"

FILE="${RSYNC_MODULE_PATH}/${RSYNC_REQUEST##$RSYNC_MODULE_NAME/}"
EXT="$(echo $RSYNC_REQUEST | grep -o '\.[^.]*$')"
PIDFILE="/tmp/rsync.$RSYNC_PID"
echo "$FILE" > "$PIDFILE"
stringinstring "winact.tar.gz.upload" "$FILE" && EXT="winact-upload"

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "RSYNC_REQUEST: $RSYNC_REQUEST"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "EXT: $EXT"

compname="$(echo $RSYNC_HOST_NAME | awk -F\. '{ print $1 }')"

case $EXT in

 # handle machine account password
 *.mpw)
  # create random machine password, set it and store it in a temporary file, which the client will download
  MACHINEPW="$(pwgen -s 10 1)"
  if ! sophomorix-passwd --force --user "$compname$" --pass "$MACHINEPW" | grep -qi "error"; then
   echo "$MACHINEPW" > "$FILE"
  fi
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
  compname="$(echo $RSYNC_HOST_NAME | awk -F \. '{ print $1 }')"
  if [ -n "$compname" ]; then
   winkey="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print $2 " " $7 }' | grep -w $compname | awk '{ print $2 }' | tr a-z A-Z)"
   officekey="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print $2 " " $6 }' | grep -w $compname | awk '{ print $2 }' | tr a-z A-Z)"
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

 *) ;;

esac

echo "RC: $RSYNC_EXIT_STATUS"
echo "### rsync pre download end: $(date) ###"

exit $RSYNC_EXIT_STATUS
