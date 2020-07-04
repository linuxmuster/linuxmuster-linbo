#
# oss helperfunctions for linbo scripts
#
# thomas@linuxmuster.net
# 20200527
#
get_group(){
 local HOSTNAME=
 local GROUP=
 get_hostname "$1"
 HOSTNAME="$RET"
 [ -n "$HOSTNAME" ] || return 1
 GROUP="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print $2 " " $3 }' | grep -i ^"$HOSTNAME " | tail -1 | awk '{ print $2 }' | tr A-Z a-z)"
 echo "$GROUP"
}

# check valid string without special characters
check_string() {
 tolower "$1"
 if (expr match "$RET" '\([abcdefghijklmnopqrstuvwxyz0-9\_\-]\+$\)') &> /dev/null; then
  return 0
 else
  return 1
 fi
}

# converting string to lower chars
tolower() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`echo $1 | tr A-Z a-z`
}

# check valid ip
validip() {
  if (expr match "$1"  '\(\([1-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([1-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)$\)') &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# test valid mac address syntax
validmac() {
  [ -z "$1" ] && return 1
  [ `expr length $1` -ne "17" ] && return 1
  if (expr match "$1" '\([a-fA-F0-9-][a-fA-F0-9-]\+\(\:[a-fA-F0-9-][a-fA-F0-9-]\+\)\+$\)') &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# test for valid hostname
validhostname() {
 [ -z "$1" ] && return 1
 tolower "$1"
 if (expr match "$RET" '\([a-z0-9\-]\+$\)') &> /dev/null; then
  return 0
 else
  return 1
 fi
}

# extract hostname from file $WIMPORTDATA
get_hostname() {
  unset RET
  [ -f "$WIMPORTDATA" ] || return 1
  local pattern="$1"
  if validip "$pattern"; then
   pattern="${pattern//./\\.}"
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $5 " " $2 }' | grep ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  elif validmac "$pattern"; then
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $4 " " $2 }' | grep -i ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  else # assume hostname
   local result=`grep -v ^# $WIMPORTDATA | tr A-Z a-z | awk -F\; '{ print $2 }' | grep -wi ^"$pattern"` &> /dev/null
   local i
   # iterate over results, get exact match
   for i in $result; do
    if [ "xxx${i}xxx" = "xxx${pattern}xxx" ]; then
     RET="$i"
     break
    else
     RET=""
    fi
   done
  fi
  [ -n "$RET" ] && tolower "$RET"
  echo "$RET"
}

# get broadcast address for specified ip address
get_bcaddress(){
python3 <<END
from functions import getIpBcAddress
try:
  ip="$1"
  print(getIpBcAddress(ip))
except:
  quit(1)
END
}

# extract mac address from file devices.csv
get_mac() {
  unset RET
  [ -f "$WIMPORTDATA" ] || return 1
  local pattern="$1"
  if validip "$pattern"; then
   pattern="${pattern//./\\.}"
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $5 " " $4 }' | grep ^"$pattern " | awk '{ print $2 }' | tr a-z A-Z` &> /dev/null
  else # assume hostname
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $2 " " $4 }' | grep -i ^"$pattern " | awk '{ print $2 }' | tr a-z A-Z` &> /dev/null
  fi
  echo "$RET"
}

# return hostgroup of device from devices.csv
get_hostgroup(){
  local clientname="$1"
  grep -v ^# "$WIMPORTDATA" | grep -wi "$clientname" | awk -F\; '{ print $2 " " $3 }' | grep -wi "$clientname" | awk '{ print $2 }'
}

# return mac address from dhcp leases
get_mac_dhcp(){
  validip "$1" || return
  LANG=C grep -A10 "$1" /var/lib/dhcp/dhcpd.leases | grep "hardware ethernet" | awk '{ print $3 }' | awk -F\; '{ print $1 }' | tr A-Z a-z
}

# return hostname by dhcp ip from devices.csv
get_hostname_dhcp_ip(){
  validip "$1" || return
  local macaddr="$(get_mac_dhcp "$1")"
  [ -z "$macaddr" ] && return
  get_hostname "$macaddr"
}

# do hostname handling for linbos rsync xfer scripts
do_rsync_hostname(){
  # handle unknown hostname in case of dynamic ip client
  if echo "$RSYNC_HOST_NAME" | grep -q UNKNOWN; then
    local compname_tmp="$(get_hostname_dhcp_ip "$RSYNC_HOST_ADDR")"
    [ -n "$compname_tmp" ] && RSYNC_HOST_NAME="$(echo "$RSYNC_HOST_NAME" | sed -e "s|UNKNOWN|$compname_tmp|")"
  fi
  compname="$(echo $RSYNC_HOST_NAME | awk -F\. '{ print $1 }' | tr A-Z a-z)"
  # get FQDN
  validdomain "$RSYNC_HOST_NAME" || RSYNC_HOST_NAME="${RSYNC_HOST_NAME}.$(hostname -d)"
  export compname
  export RSYNC_HOST_NAME
}

# test if string is in string
stringinstring() {
  case "$2" in *$1*) return 0;; esac
  return 1
}

# test if variable is an integer
isinteger () {
  [ $# -eq 1 ] || return 1

  case $1 in
  *[!0-9]*|"") return 1;;
            *) return 0;;
  esac
} # isinteger

# extract ip address from file $WIMPORTDATA
get_ip() {
  unset RET
  [ -f "$WIMPORTDATA" ] || return 1
  local pattern="$1"
  if validmac "$pattern"; then
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $4 " " $5 }' | grep -i ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  else # assume hostname
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $2 " " $5 }' | grep -i ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  fi
  echo "$RET"
}

# get pxe flag: get_pxe ip|host
get_pxe() {
 [ -f "$WIMPORTDATA" ] || return 1
 local pattern="$1"
 local res
 local i
 if validip "$pattern"; then
  res="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | grep \;$pattern\; | awk -F\; '{ print $11 }')"
 else
  # assume hostname
  get_ip "$pattern"
  # perhaps a host with 2 ips
  for i in $RET; do
   if [ -z "$res" ]; then
    res="$(get_pxe "$i")"
   else
    res="$res $(get_pxe "$i")"
   fi
  done
 fi
 echo "$res"
}

# check valid ip
validip() {
  if (expr match "$1"  '\(\([1-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([1-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)$\)') &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# test valid mac address syntax
validmac() {
  [ -z "$1" ] && return 1
  [ `expr length $1` -ne "17" ] && return 1
  if (expr match "$1" '\([a-fA-F0-9-][a-fA-F0-9-]\+\(\:[a-fA-F0-9-][a-fA-F0-9-]\+\)\+$\)') &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# print kernel options from start.conf
linbo_kopts(){
 local conf="$1"
 [ -z "$conf" ] && return
 local kopts
 if [ -e "$conf" ]; then
  kopts="$(grep -i ^kerneloptions "$conf" | tail -1 | sed -e 's/#.*$//' -e 's/kerneloptions//I' | awk -F\= '{ print substr($0, index($0,$2)) }' | sed -e 's/ =//' -e 's/^ *//g' -e 's/ *$//g')"
 fi
 echo "$kopts"
}


# test if host is opsimanaged: opsimanaged ip|host
opsimanaged() {
 local res="$(get_pxe "$1")"
 local i
 for i in $res; do
  isinteger "$i" || continue
  [ "$i" = "2" -o "$i" = "3" ] && return 0
 done
 return 1
}

# get_compname_from_rsync RSYNC_HOST_NAME
get_compname_from_rsync(){
  local rsync_host_name="$1"
  local compname="$(echo $rsync_host_name | awk -F\. '{ print $1 }' | tr A-Z a-z)"
  echo "$compname"
}

# save_image_macct compname image
save_image_macct(){
  local compname="$1"
  local image="$2"
  local LDBSEARCH="$(which ldbsearch)"
  if [ -n "$compname" -a -n "$LDBSEARCH" -a -n "$basedn" ]; then
   #  fetch samba nt password hash from ldap machine account
   url="--url=/var/lib/samba/private/sam.ldb"
   unicodepwd="$("$LDBSEARCH" "$url" "(&(sAMAccountName=$compname$))" unicodePwd | grep ^unicodePwd:: | awk '{ print $2 }')"
   suppcredentials="$("$LDBSEARCH" "$url" "(&(sAMAccountName=$compname$))" supplementalCredentials | sed -n '/^'supplementalCredentials':/,/^$/ { /^'supplementalCredentials':/ { s/^'supplementalCredentials': *// ; h ; $ !d}; /^ / { H; $ !d}; /^ /! { x; s/\n //g; p; q}; $ { x; s/\n //g; p; q} }' | awk '{ print $2 }')"
   if [ -n "$unicodepwd" ]; then
    echo "Writing samba password hash file for image $image."
    template="$LINBOTPLDIR/machineacct"
    imagemacct="$LINBODIR/$image.macct"
    sed -e "s|@@unicodepwd@@|$unicodepwd|" -e "s|@@suppcredentials@@|$suppcredentials|" "$template" > "$imagemacct"
    chmod 600 "$imagemacct"
   else
    rm -f "$imagemacct"
   fi
  fi
}

# upload_pwd_to_ldap compname imagemacct
upload_password_to_ldap(){
  local compname="$1"
  local imagemacct="$LINBODIR/$2"
  local url="--url=/var/lib/samba/private/sam.ldb"
  local LDBSEARCH="$(which ldbsearch) $url"
  local LDBMODIFY="$(which ldbmodify) $url"
  # upload samba machine password hashes to host's ad machine account
  if [ -s "$imagemacct" ]; then
   echo "Machine account ldif file: $imagemacct"
   echo "Host: $compname"
   # get dn of host
   dn="$($LDBSEARCH "(&(sAMAccountName=$compname$))" | grep ^dn | awk '{ print $2 }')"
   if [ -n "$dn" ]; then
    echo "DN: $dn"
    ldif="/var/tmp/${compname}_macct.$$"
    ldbopts="--nosync --verbose --controls=relax:0 --controls=local_oid:1.3.6.1.4.1.7165.4.3.7:0 --controls=local_oid:1.3.6.1.4.1.7165.4.3.12:0"
    sed -e "s|@@dn@@|$dn|" "$imagemacct" > "$ldif"
    $LDBMODIFY $ldbopts "$ldif"
    rm -f "$ldif"
   else
    echo "Cannot determine DN of $compname! Aborting!"
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
 btmaketorrent http://${serverip}:${port}/announce "$image" ; RC="$?"
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

# get_win_key compname
get_win_key(){
  local compname="$1"
  local winkey="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print $2 " " $7 }' | grep -w $compname | awk '{ print $2 }' | tr a-z A-Z)"
  echo "$winkey"
}

# get_office_key compname
get_office_key(){
  local compname="$1"
  local officekey="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print $2 " " $6 }' | grep -w $compname | awk '{ print $2 }' | tr a-z A-Z)"
  echo "$officekey"
}

# return value of RestoreOpsiState from start.conf: restoreopsistate clientname imagename.opsi
restoreopsistate() {
  local clientname="$(echo "$1" | awk -F \. '{ print $1 }' | tr A-Z a-z)"
  local imagename="$(echo "$2" | sed -e 's|.opsi||')"
  local hostgroup="$(get_hostgroup "$clientname")"
  local startconf="$LINBODIR/start.conf.$hostgroup"
  local line
  local imagefound="no"
  local result
  local ocount=0
  local icount=0
  grep -v ^# "$startconf" | grep -i ^[br][ae][s][et][io][mr][ae][go][ep] | while read line; do
    if echo "$line" | grep -qi ^baseimage; then
      icount=$((icount + 1))
      echo "$line" | grep -qw "$imagename" && imagefound="yes"
    fi
    if echo "$line" | grep -qi ^restoreopsistate; then
      ocount=$((ocount + 1))
      result="$(echo "$line" | awk -F\= '{ print $2 }' | awk -F\# '{ print $1 }' | awk '{ print $1 }' | tr A-Z a-z)"
    fi
    if [ $ocount -eq $icount -a "$imagefound" = "yes" ]; then
      echo -n "$result"
      return
    fi
  done
}

# return list of of productids from start.conf: forceopsisetup clientname imagename.opsi
forceopsisetup() {
  local clientname="$(echo "$1" | awk -F \. '{ print $1 }' | tr A-Z a-z)"
  local imagename="$(echo "$2" | sed -e 's|.opsi||')"
  local hostgroup="$(get_hostgroup "$clientname")"
  local startconf="$LINBODIR/start.conf.$hostgroup"
  local line
  local imagefound="no"
  local result
  local ocount=0
  local icount=0
  grep -v ^# "$startconf" | grep -i ^[bf][ao][sr][ec][ie][mo][ap][gs][ei] | while read line; do
    if echo "$line" | grep -qi ^baseimage; then
      icount=$((icount + 1))
      echo "$line" | grep -qw "$imagename" && imagefound="yes"
    fi
    if echo "$line" | grep -qi ^forceopsisetup; then
      ocount=$((ocount + 1))
      result="$(echo "$line" | awk -F\= '{ print $2 }' | awk -F\# '{ print $1 }' | awk '{ print $1 }' | tr A-Z a-z)"
    fi
    if [ $ocount -eq $icount -a "$imagefound" = "yes" ]; then
      echo -n "$result"
      return
    fi
  done
}
