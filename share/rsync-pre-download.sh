#!/bin/bash
#
# Pre-Download script for rsync/LINBO
# $Id: rsync-pre-download.sh 1271 2012-02-08 12:28:01Z tschmitt $

# read in paedml specific environment
[ -e /usr/share/linuxmuster/config/dist.conf ] && . /usr/share/linuxmuster/config/dist.conf

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

EXT="$(echo $RSYNC_REQUEST | grep -o '\.[^.]*$')"

echo "RSYNC_REQUEST: $RSYNC_REQUEST"
echo "EXT: $EXT"

case $EXT in

 *.macct)
  LDAPMODIFY="$(which ldapmodify)"
  LDAPSEARCH="$(which ldapsearch)"
  imagemacct="$LINBODIR/${RSYNC_REQUEST##*/}"
  ldapsec="/etc/ldap.secret"
  # upload samba machine password hashes to host's machine account
  if [ -s "$imagemacct" -a -s "$NETWORKSETTINGS" -a -s "$ldapsec" -a -n "$LDAPMODIFY" ]; then
   # read basedn
   . $NETWORKSETTINGS
   compname="$(echo $RSYNC_HOST_NAME | awk -F\. '{ print $1 }')"
   echo "Machine account file: $imagemacct"
   echo "Host: $compname"
   echo "Writing samba machine password hashes to ldap account:"
   sed -e "s|@@compname@@|$compname|" "$imagemacct" | "$LDAPMODIFY" -x -y "$ldapsec" -D "cn=admin,$basedn" -h localhost
   # check for success
   sambaNTpwhash_cur="$("$LDAPSEARCH" -y "$ldapsec" -D cn=admin,$basedn -x -h localhost "(uid=$compname$)" sambaNTPassword | grep ^sambaNTPassword: | awk '{ print $2 }')"
   sambaNTpwhash_new="$(grep ^sambaNTPassword: "$imagemacct" | awk '{ print $2 }')"
   if [ "$sambaNTpwhash_new" != "$sambaNTpwhash_cur" ]; then
    echo "Not successfull, once again:"
    sed -e "s|@@compname@@|$compname|" "$imagemacct" | "$LDAPMODIFY" -x -y "$ldapsec" -D "cn=admin,$basedn" -h localhost
   fi
  fi
 ;;

 *) ;;

esac

echo "RC: $RSYNC_EXIT_STATUS"
echo "### rsync pre download end: $(date) ###"

exit $RSYNC_EXIT_STATUS

