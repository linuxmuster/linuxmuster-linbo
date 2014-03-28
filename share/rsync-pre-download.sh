#!/bin/bash
#
# Pre-Download script for rsync/LINBO
# thomas@linuxmuster.net
# 28.03.2014
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

pcname="$(echo $RSYNC_HOST_NAME | awk -F\. '{ print $1 }')"

case $EXT in

 # write machine password hash to host's samba/ldap account
 *.macct)
  LDAPMODIFY="$(which ldapmodify)"
  LDAPSEARCH="$(which ldapsearch)"
  imagemacct="$LINBODIR/${RSYNC_REQUEST##*/}"
  ldapsec="/etc/ldap.secret"
  # upload samba machine password hashes to host's machine account
  if [ -s "$imagemacct" -a -n "$basedn" ]; then
   echo "Machine account file: $imagemacct"
   echo "Host: $pcname"
   echo "Writing samba machine password hashes to ldap account:"
   sed -e "s|@@pcname@@|$pcname|" "$imagemacct" | "$LDAPMODIFY" -x -y "$ldapsec" -D "cn=admin,$basedn" -h localhost
   # check for success
   sambaNTpwhash_cur="$("$LDAPSEARCH" -y "$ldapsec" -D cn=admin,$basedn -x -h localhost "(uid=$pcname$)" sambaNTPassword | grep ^sambaNTPassword: | awk '{ print $2 }')"
   sambaNTpwhash_new="$(grep ^sambaNTPassword: "$imagemacct" | awk '{ print $2 }')"
   if [ "$sambaNTpwhash_new" != "$sambaNTpwhash_cur" ]; then
    echo "Not successfull, once again:"
    sed -e "s|@@pcname@@|$pcname|" "$imagemacct" | "$LDAPMODIFY" -x -y "$ldapsec" -D "cn=admin,$basedn" -h localhost
   fi
  fi
 ;;

 # provide host's opsi key for download
 *.opsikey)
  # invoked by linbo_cmd on postsync
  # if opsi server is configured and host is opsimanaged
  if ([ -n "$opsiip" ] && opsimanaged "$pcname"); then
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
  pcname="$(echo $RSYNC_HOST_NAME | awk -F \. '{ print $1 }')"
  [ -n "$pcname" ] && winkey="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print $2 " " $7 }' | grep -w $pcname | awk '{ print $2 }' | tr a-z A-Z)"
  [ -n "$winkey" ] && echo "$winkey" > "$FILE"
 ;;

 # handle windows activation tokens archive
 winact-upload)
  FILE="${FILE%.upload}"
  # fetch archive from client
  echo "Upload request for windows activation tokens archive."
  linbo-scp "${RSYNC_HOST_NAME}:/cache/$(basename $FILE)" "$FILE"
  rm -f "$PIDFILE"
 ;;

 *) ;;

esac

echo "RC: $RSYNC_EXIT_STATUS"
echo "### rsync pre download end: $(date) ###"

exit $RSYNC_EXIT_STATUS
