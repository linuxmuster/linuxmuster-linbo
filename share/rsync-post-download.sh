#!/bin/bash
#
# Post-Download script for rsync/LINBO
# thomas@linuxmuster.net
# 12.10.2014
#

# read in paedml specific environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

LOGFILE="$LINBODIR/log/rsync-post-download.log"

# Debug
exec >>$LOGFILE 2>&1
#echo "$0 $*, Variables:" ; set

echo "### rsync post download begin: $(date) ###"

# Needs Version 2.9 of rsync
[ -n "$RSYNC_PID" ] || exit 0

PIDFILE="/tmp/rsync.$RSYNC_PID"

# Check for pidfile, exit if nothing to do
[ -s "$PIDFILE" ] || exit 0

# read file created by pre-upload script
FILE="$(<$PIDFILE)"
EXT="$(echo $FILE | grep -o '\.[^.]*$')"

echo "HOSTNAME: $RSYNC_HOST_NAME"
echo "FILE: $FILE"
echo "PIDFILE: $PIDFILE"
echo "EXT: $EXT"

pcname="$(echo $RSYNC_HOST_NAME | awk -F \. '{ print $1 }')"

case $EXT in

 # remove linbocmd file after download
 *.cmd)
  echo "Removing onboot linbocmd file $FILE."
  rm -f "$FILE"
 ;;

 # update host's opsi ini, invoked by linbo_cmd on postsync
 *.opsi)
  # take requested file from pre-download script
  imageini="$FILE"
  # if opsi server is configured and host is opsimanaged
  if ([ -n "$opsiip" -a -s "$imageini" ] && opsimanaged "$pcname"); then
   # get host's inifile from opsi server
   clientini="${opsiip}:$OPSICLIENTDIR/${RSYNC_HOST_NAME}.ini"
   origini="/var/tmp/$(basename "$clientini")"
   newini="/var/tmp/$(basename "$clientini").new"
   echo "clientini: $clientini"
   echo "origini: $origini"
   echo "newini: $newini"
   rsync "$clientini" "$origini"
   # if download of inifile was successful
   if [ -s "$origini" ]; then
    echo "$origini successfully downloaded!"
    # get windows keys from file if any
    licensekey="$(grep ^poolid-or-licensekey "$origini" | awk -F\" '{ print $2 }')"
    productkey="$(grep ^productkey "$origini" | awk -F\" '{ print $2 }')"
    # copy header from original ini to new ini
    sed -n '/^\[info\]/,/^\[localboot_product_states\]/p' "$origini" | sed -n '/^\[localboot_product_states\]/!p' > "$newini"
    # take opsi product states from image ini 
    sed -n '/^\[localboot_product_states\]/,$p' "$imageini" >> "$newini"
    # patch license keys
    [ -n "$licensekey" ] && sed -e "s|^poolid-or-licensekey.*|poolid-or-licensekey = \[\"$licensekey\"\]|" -i "$newini"
    [ -n "$productkey" ] && sed -e "s|^productkey.*|productkey = \[\"$productkey\"\]|" -i "$newini"
    # upload the new inifile
    rsync "$newini" "$clientini" ; RC="$?"
    [ "$RC" = "0" ] || echo "Upload of $(basename "$newini") to opsi failed!"
    # repair opsi's file permissions
    ssh "$opsiip" opsi-setup --set-rights "$OPSICLIENTDIR"
   fi
   rm -f "$origini" "$newini"
  fi
 ;;

 *.opsikey)
  if [ -e "$FILE" ]; then
   echo "Removing opsi key file $FILE."
   rm -f "$FILE"
  fi
 ;;

 *.winkey)
  if [ -e "$FILE" ]; then
   echo "Removing windows product key file $FILE."
   rm -f "$FILE"
  fi
 ;;

 *.gz)
  # repair old linbofs filename
  if [ "$(basename "$FILE")" = "linbofs.gz" ]; then
    linbo-scp "$LINBODIR/linbofs.lz" "${RSYNC_HOST_NAME}:/cache"
    linbo-ssh "$RSYNC_HOST_NAME" /bin/sed -e \"s/linbofs.gz/linbofs.lz/g\" -i /cache/boot/grub/menu.lst
    linbo-ssh "$RSYNC_HOST_NAME" /bin/rm /cache/linbofs.gz /cache/linbo*.info
  fi
  # repair old linbofs64 filename
  if [ "$(basename "$FILE")" = "linbofs64.gz" ]; then
    linbo-scp "$LINBODIR/linbofs64.lz" "${RSYNC_HOST_NAME}:/cache"
    linbo-ssh "$RSYNC_HOST_NAME" /bin/sed -e \"s/linbofs64.gz/linbofs64.lz/g\" -i /cache/boot/grub/menu.lst
    linbo-ssh "$RSYNC_HOST_NAME" /bin/rm /cache/linbofs64.gz /cache/linbo64*.info
  fi
 ;;

esac

rm -f "$PIDFILE"
