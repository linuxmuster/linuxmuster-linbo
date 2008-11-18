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

# Check for backup file that should have been created by pre-upload script
if [ -s "$BACKUP" ]; then
 if [ "$RSYNC_EXIT_STATUS" = "0" ]; then
  echo "Upload of ${FILE##*/} was successful." >&2
  DATE="$(date +'%Y-%m-%d-%H%M')" # YYYY-MM-DD-hhmm
  BASE="${FILE##*/}" ; EXT="$BASE"; BASE="${BASE%%.*}" ; EXT="${EXT##$BASE}" # File Extension
  ARCHIVE="${FILE%%$EXT}-$DATE$EXT"
  mv -fv "$BACKUP" "$ARCHIVE"
  echo "Archive file ${ARCHIVE##*/} created." >&2
 else
 # If upload failed, move old file back from backup.
  echo "Upload of ${FILE##*/} failed." >&2
  mv -fv "$BACKUP" "$FILE"
  echo "Recovered ${FILE##*/} from backup." >&2
 fi
fi

# add new host file to workstation data
if [ "$(echo $FILE | grep -o '\.[^.]*$')" = ".new" ]; then
 echo "Adding $FILE to $WIMPORTDATA."
 cat $FILE >> $WIMPORTDATA
 rm $FILE
fi

exit $RSYNC_EXIT_STATUS

