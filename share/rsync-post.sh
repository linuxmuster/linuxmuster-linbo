#!/bin/bash
# (C) Klaus Knopper 2007
# License: GPL V2
# Post-Upload script for rsync/LINBO:
# Moves old version of file out of the way,
# and installs a new version.

# Debug
exec >>/var/log/linuxmuster/linbo/rsync.log 2>&1
echo "$0 $*, Variables:" ; set

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

PIDFILE="/tmp/rsync.$RSYNC_PID"

# Check for pidfile, quit if nothing to do
[ -s "$PIDFILE" ] || exit 0

# read in paedml specific environment
[ -e /usr/share/linuxmuster/config/dist.conf ] && . /usr/share/linuxmuster/config/dist.conf

FILE="$(<$PIDFILE)"
rm -f "$PIDFILE"
BACKUP="${FILE}.BAK"
EXT="$(echo $FILE | grep -o '\.[^.]*$')"

# Check for backup file that should have been created by pre-upload script
if [ -s "$BACKUP" ]; then
 if [ "$RSYNC_EXIT_STATUS" = "0" ]; then
  echo "Upload of ${FILE##*/} was successful." >&2
  DATE="$(date +'%Y-%m-%d-%H%M')" # YYYY-MM-DD-hhmm
  ARCHIVE="${FILE%%$EXT}-$DATE$EXT"
  mv -fv "$BACKUP" "$ARCHIVE"
  echo "Archive file ${ARCHIVE##*/} created." >&2
  # if it was an image file restart multicast service if it is enabled
  if [ "$EXT" = ".cloop" -o "$EXT" = ".rsync" ]; then
   echo "Image file ${FILE##*/} detected. Restarting multicast service if enabled." >&2
   /etc/init.d/linbo-multicast restart >&2
  fi
  # if it was a torrent file restart bittorrent service for this file
  if [ "$EXT" = ".torrent" ]; then
   timage="$(btshowmetainfo "$LINBODIR/${FILE##*/}" | grep ^"file name" | awk '{ print $3 }')"
   echo "Torrent file for $timage detected. Restarting bittorrent service." >&2
   /etc/init.d/linbo-bittorrent restart >&2
   /etc/init.d/bittorrent restart >&2
  fi
 else
 # If upload failed, move old file back from backup.
  echo "Upload of ${FILE##*/} failed." >&2
  mv -fv "$BACKUP" "$FILE"
  echo "Recovered ${FILE##*/} from backup." >&2
 fi
fi

# add new host file to workstation data
if [ "$EXT" = ".new" ]; then
 ROW="$(cat $FILE)"
 if grep "$ROW" $WIMPORTDATA | grep -qv ^#; then
  echo "Row already present in workstations data file. Skipped!" >&2
 else
  echo "Adding row to $WIMPORTDATA." >&2
  cat $FILE >> $WIMPORTDATA
 fi
 rm $FILE
fi

exit $RSYNC_EXIT_STATUS

