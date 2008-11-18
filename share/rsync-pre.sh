#!/bin/bash
# (C) Klaus Knopper 2007
# License: GPL V2
# Pre-Upload script for rsync/LINBO:
# Moves old version of file out of the way,
# and installs a new version.

# Debug
exec >>/var/log/linuxmuster/linbo/rsync.log 2>&1
echo "$0 $*, Variables:" ; set

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

FILE="${RSYNC_MODULE_PATH}/${RSYNC_REQUEST##$RSYNC_MODULE_NAME/}"
BACKUP="${FILE}.BAK"
PIDFILE="/tmp/rsync.$RSYNC_PID"

# Save filename for post-script and exit, if it is a new host data file
if [ "$(echo $FILE | grep -o '\.[^.]*$')" = ".new" ]; then
 [ -e "$PIDFILE" ] && rm -f "$PIDFILE"
 echo "$FILE" > "$PIDFILE"
 exit 0
fi

# Bailout with error if backup file exists (another process is uploading)
if [ -s "$BACKUP" ]; then
 echo "Backup file exists for ${FILE##*/}, another upload in progress?" >&2
 exit 1
fi

# Continue without creating backups, if file does not exist yet.
[ -d "$FILE" ] && exit 0
[ -s "$FILE" ] || exit 0

# Move file out of the way
mv -fv "$FILE" "$BACKUP" ; RC="$?"

# Save filename for post-script and exit
[ "$RC" = "0" ] && { rm -f "$PIDFILE" ; echo "$FILE" > "$PIDFILE"; }
exit $RC
# post-script will change the name of the backup to a more meaningful one,
# or rename it back in case of a failed download.
