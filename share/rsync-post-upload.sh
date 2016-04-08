#!/bin/bash
# (C) Klaus Knopper 2007
# License: GPL V2
# Post-Upload script for rsync/LINBO:
# Moves old version of file out of the way,
# and installs a new version.
#
# thomas@linuxmuster.net
# 13.07.2015
#

# read in paedml specific environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

LOGFILE=rsync-post-upload.log
if [ -n "$LINBODIR" ]; then
 LOGFILE="$LINBODIR/log/$LOGFILE"
else
 LOGFILE="/var/log/$LOGFILE"
fi

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync post upload begin: $(date) ###"

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

PIDFILE="/tmp/rsync.$RSYNC_PID"

# Check for pidfile, exit if nothing to do
[ -s "$PIDFILE" ] || exit 0

FILE="$(<$PIDFILE)"
rm -f "$PIDFILE"
BACKUP="${FILE}.BAK"
FTYPE="$(echo $FILE | grep -o '\.[^.]*$')"

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "BACKUP: $BACKUP"
echo "FTYPE: $FTYPE"

# Check for backup file that should have been created by pre-upload script
if [ -s "$BACKUP" ]; then
 if [ "$RSYNC_EXIT_STATUS" = "0" ]; then
  echo "Upload of ${FILE##*/} was successful." >&2
  DATE="$(date +'%Y-%m-%d-%H%M')" # YYYY-MM-DD-hhmm
  BASE="${FILE##*/}" ; EXT="$BASE"; BASE="${BASE%%.*}" ; EXT="${EXT##$BASE}" # File Extension
  ARCHIVE="${FILE%%$EXT}-$DATE$EXT"
  mv -fv "$BACKUP" "$ARCHIVE"
  echo "Archive file ${ARCHIVE##*/} created." >&2
  # backup macct and opsi files
  case "$FTYPE" in
   *.cloop|*.rsync)
    for i in macct opsi; do
     if [ -e "${FILE}.$i" ];then
      mv -fv "${FILE}.$i" "${ARCHIVE}.$i"
      echo "$(basename ${ARCHIVE}.$i) created."
      chmod 600 "${ARCHIVE}.$i"
     fi
    done
   ;;
  esac
 else
 # If upload failed, move old file back from backup.
  echo "Upload of ${FILE##*/} failed." >&2
  mv -fv "$BACKUP" "$FILE"
  echo "Recovered ${FILE##*/} from backup." >&2
 fi
fi

# do something depending on file type
case "$FTYPE" in

 *.cloop|*.rsync)
  image="${FILE##*/}"
  # restart multicast service if image file was uploaded.
  echo "Image file $image detected. Restarting multicast service if enabled." >&2
  /etc/init.d/linbo-multicast restart >&2

  # save samba passwords of host we made the new image
  LDAPSEARCH="$(which ldapsearch)"
  ldapsec="/etc/ldap.secret"
  compname="$(echo $RSYNC_HOST_NAME | awk -F\. '{ print $1 }')"
  if [ -n "$RSYNC_HOST_NAME" -a -n "$LDAPSEARCH" -a -s "$ldapsec" -a -n "$NETWORKSETTINGS" ]; then
   #  fetch samba nt password hash from ldap machine account
   . $NETWORKSETTINGS # read basedn
   sambaNTpwhash="$("$LDAPSEARCH" -y "$ldapsec" -D cn=admin,$basedn -x -h localhost "(uid=$compname$)" sambaNTPassword | grep ^sambaNTPassword: | awk '{ print $2 }')"
   if [ -n "$sambaNTpwhash" ]; then
    echo "Writing samba password hash file for image $image."
    template="$LINBOTPLDIR/machineacct"
    imagemacct="$LINBODIR/$image.macct"
    sed -e "s|@@basedn@@|$basedn|
            s|@@sambaNTpwhash@@|$sambaNTpwhash|" "$template" > "$imagemacct"
    chmod 600 "$imagemacct"
   fi
  fi

  # update opsi settings if host is managed
  if ([ -n "$opsiip" ] && opsimanaged "$compname"); then
   clientini="${opsiip}:$OPSICLIENTDIR/${RSYNC_HOST_NAME}.ini"
   imageini="$LINBODIR/$image.opsi"
   rsync "$clientini" "$imageini" ; RC="$?"
   if [ "$RC" = "0" ]; then
    chmod 600 "$imageini"
    echo "$(basename "$clientini") successfully downloaded to $(basename "$imageini")."
   else
    rm -f "$imageini"
    echo "Download of $(basename "$clientini") to $(basename "$imageini") failed!"
   fi
  fi

 ;;

 *.torrent)
  # restart torrent service if torrent file was uploaded.
  echo "Torrent file ${FILE##*/} detected. Restarting bittorrent service." >&2
  /etc/init.d/linbo-bittorrent restart >&2
 ;;
 *.new)
  # add new host data to workstations file
  ROW="$(cat $FILE)"
  if grep -i "$ROW" $WIMPORTDATA | grep -qv ^#; then
   echo "$ROW"
   echo "is already present in workstations file. Skipped!" >&2
  else
   echo "Adding row to $WIMPORTDATA." >&2
   echo "$ROW" >> $WIMPORTDATA
   # save last registered host
   echo "$ROW" > "$LINBODIR/last_registered"
  fi
  rm $FILE
 ;;
 *) ;;
esac

echo "RC: $RSYNC_EXIT_STATUS"
echo "### rsync post upload end: $(date) ###"

exit $RSYNC_EXIT_STATUS

