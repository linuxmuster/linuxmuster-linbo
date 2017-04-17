#
# lmn6 helperfunctions for linbo scripts
#
# thomas@linuxmuster.net
# 22.03.2015
#

# fschuett
# fetch SystemType from start.conf
systemtype(){
 local group="$1"
 local systemtype="bios"
 [ -n "$group" ] || return 1
 [ -s $LINBODIR/start.conf.$group ] || return 1
 systemtype=`grep -i ^SystemType $LINBODIR/start.conf.$group | tail -1 | awk -F= '{ print $2 }' | awk '{ print $1 }'`
 echo "$systemtype"
}

kerneltype(){
 local group="$1"
 local kerneltype="linbo"
 [ -n "$group" ] || return 1
 local systemtype=$(systemtype $group)
 case $systemtype in
   bios64|efi64)
       kerneltype="linbo64"
   ;;
   *)
   ;;
 esac
 echo "$kerneltype"
}

kernelfstype(){
 local group="$1"
 local kernelfstype="linbofs.lz"
 [ -n "$group" ] || return 1
 local systemtype=$(systemtype $group)
 case $systemtype in
   bios64|efi64)
       kernelfstype="linbofs64.lz"
   ;;
   *)
   ;;
 esac
 echo "$kernelfstype"
}

# get_compname_from_rsync RSYNC_HOST_NAME
get_compname_from_rsync(){
  local rsync_host_name="$1"
  local compname="$(echo $rsync_host_name | awk -F\. '{ print $1 }')"
  echo "$compname"
}

# save_image_macct compname image
save_image_macct(){
  local compname="$1"
  local image="$2"
  local LDAPSEARCH="$(which ldapsearch)"
  local ldapsec="/etc/ldap.secret"
  local sambaNTpwhash
  if [ -n "$compname" -a -n "$LDAPSEARCH" -a -s "$ldapsec" -a -n "$NETWORKSETTINGS" ]; then
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
}

# upload_password_to_ldap compname imagemacct
upload_password_to_ldap(){
  local compname="$1"
  local imagemacct="$LINBODIR/$2"
  local LDAPMODIFY="$(which ldapmodify)"
  local LDAPSEARCH="$(which ldapsearch)"
  local ldapsec="/etc/ldap.secret"
  # upload samba machine password hashes to host's machine account
  if [ -s "$imagemacct" -a -n "$basedn" ]; then
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
}

# get active groups
get_active_groups(){
  local actgroups="$(grep ^[-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789] $WIMPORTDATA | awk -F\; '{ print $3 }' | sort -u)"
  echo "$actgroups"
}

# return active images
active_images() {
 # check for workstation data
 [ -z "$WIMPORTDATA" ] && return 1
 [ -s "$WIMPORTDATA" ] || return 1
 # get active groups
 local actgroups="$(get_active_groups)"
 [ -z "$actgroups" ] && return 0
 # compute images used by active groups
 local tmpfile=/var/tmp/active_images.$$
 rm -f $tmpfile
 touch $tmpfile || return 1
 local i=""
 for i in $actgroups; do
  if [ -s "$LINBODIR/start.conf.$i" ]; then
   grep -i ^baseimage $LINBODIR/start.conf.$i | awk -F\= '{ print $2 }' | awk '{ print $1 }' >> $tmpfile
   grep -i ^image $LINBODIR/start.conf.$i | awk -F\= '{ print $2 }' | awk '{ print $1 }' >> $tmpfile
  fi
 done
 local actimages="$(sort -u $tmpfile)"
 rm $tmpfile
 for i in $actimages; do
  [ -s "$LINBODIR/$i" ] && echo "$i"
 done
 return 0
}

# create torrent file for image
create_torrent() {
 local image="$1"
 local RC=1
 cd "$LINBODIR"
 [ -s "$image" ] || return "$RC"
 local serverip="$2"
 local port="$3"
 echo "Creating $image.torrent ..."
 btmakemetafile "$image" http://${serverip}:${port}/announce ; RC="$?"
 return "$RC"
}

# test for pxe
is_pxe(){
  local IP="$1"
  local pxe="$(grep -i ^[a-z0-9] $WIMPORTDATA | grep -w "$IP" | awk -F\; '{ print $11 }')"
  return "$pxe"
}

# get IPs from group
get_ips_from_group(){
  local GROUP="$1"
  local IP="$(grep -i ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $3, $5, $11 }' | grep ^"$GROUP " | grep -v " 0" | awk '{ print $2 }')"
  echo "$IP"
}

# get IPs from room
get_ips_from_room(){
  local ROOM="$1"
  local IP="$(grep -i ^[a-z0-9] $WIMPORTDATA | awk -F\; '{ print $1, $5, $11 }' | grep ^"$ROOM " | grep -v " 0"  | awk '{ print $2 }')"
  echo "$IP"
}
