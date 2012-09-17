#!/bin/bash
# (C) Klaus Knopper 2007
# License: GPL V2
# Pre-Upload script for rsync/LINBO:
# Moves old version of file out of the way,
# and installs a new version.
#
# later improvements by Thomas Schmitt
# $Id: rsync-pre-upload.sh 1271 2012-02-08 12:28:01Z tschmitt $
#

# read in paedml specific environment
[ -e /usr/share/linuxmuster/config/dist.conf ] && . /usr/share/linuxmuster/config/dist.conf

LOGFILE=rsync-pre-upload.log
if [ -n "$LINBODIR" ]; then
 LOGFILE="$LINBODIR/log/$LOGFILE"
else
 LOGFILE="/var/log/$LOGFILE"
fi

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync pre upload begin: $(date) ###"

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

FILE="${RSYNC_MODULE_PATH}/${RSYNC_REQUEST##$RSYNC_MODULE_NAME/}"
BACKUP="${FILE}.BAK"
PIDFILE="/tmp/rsync.$RSYNC_PID"

# Save filename for post-script and exit, if it is a new host data file
EXT="$(echo $FILE | grep -o '\.[^.]*$')"

echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "BACKUP: $BACKUP"
echo "EXT: $EXT"

if [ "$EXT" = ".new" ]; then
 [ -e "$PIDFILE" ] && rm -f "$PIDFILE"
 echo "$FILE" > "$PIDFILE"
 exit 0
fi

# Bailout with error if backup file exists (another process is uploading)
if [ -s "$BACKUP" ]; then
 echo "Backup file exists for ${FILE##*/}, another upload in progress?" >&2
 exit 1
fi

# Create backups, if file exists, otherwise save only the filename.
[ -d "$FILE" ] && exit 0
if [ -e "$FILE" ]; then
 # Move file out of the way
 mv -fv "$FILE" "$BACKUP" ; RC="$?"
else
 RC=0
fi

# Save filename for post-script and exit
[ "$RC" = "0" ] && { rm -f "$PIDFILE" ; echo "$FILE" > "$PIDFILE"; }

echo "RC: $RC"
echo "### rsync pre upload end: $(date) ###"

exit $RC
# post-script will change the name of the backup to a more meaningful one,
# or rename it back in case of a failed download.
