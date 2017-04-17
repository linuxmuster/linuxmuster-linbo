# linuxmuster shell helperfunctions
#
# thomas@linuxmuster.net
# 19.01.2016
# GPL v3
#

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# lockfile
lockflag=/tmp/.linbo.lock

# date & time
[ -e /bin/date ] && DATETIME=`date +%y%m%d-%H%M%S`


####################
# common functions #
####################

# test if variable is an integer
isinteger () {
  [ $# -eq 1 ] || return 1

  case $1 in
  *[!0-9]*|"") return 1;;
            *) return 0;;
  esac
} # isinteger


# backup up files gzipped to /var/adm/backup
backup_file() {
	[ -z "$1" ] && return 1
	[ -e "$1" ] || return 1
	echo "Backing up $1 ..."
	origfile=${1#\/}
	backupfile=$BACKUPDIR/$origfile-$DATETIME.gz
	origpath=`dirname $1`
	origpath=${origpath#\/}
	[ -d "$BACKUPDIR/$origpath" ] || mkdir -p $BACKUPDIR/$origpath
	gzip -c $1 > $backupfile || return 1
	return 0
}

##########################
# check parameter values #
##########################

# check valid ip
validip() {
  if (expr match "$1"  '\(\([1-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)\.\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-4]\)$\)') &> /dev/null; then
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


###############
# linbo stuff #
###############

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

get_hwconf_group(){
 local host="$1"
 local hwconf="$(oss_ldapsearch "(&(objectclass=SchoolWorkstation)(cn=$1))" configurationValue | grep '^configurationValue: HW=' | sed 's/configurationValue: HW=//')"
 local group="$(oss_ldapsearch "(&(objectclass=SchoolConfiguration)(configurationKey=$hwconf))" description | grep '^description: ' | sed 's/description: //')"
 echo "$group"
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
  local LDBSEARCH="$(which oss_ldapsearch)"
  if [ -n "$compname" -a -n "$LDBSEARCH" ]; then
   #  fetch samba nt password hash from ldap machine account
   local sambaNTpwhash="$("$LDBSEARCH" "uid=$compname$" sambaNTPassword | grep ^sambaNTPassword: | awk '{ print $2 }')"
   local basedn="$(cat /etc/sysconfig/ldap | grep '^BIND_DN=' | awk -F\= '{ print $2 }' | sed 's/"//g')"
   bsedn=${basedn#*,}
   if [ -n "$sambaNTpwhash" ]; then
    echo "Writing samba password hash file for image $image."
    local template="$LINBOTPLDIR/machineacct"
    local imagemacct="$LINBODIR/$image.macct"
    sed -e "s|@@basedn@@|$basedn|
            s|@@sambaNTpwhash@@|$sambaNTpwhash|" "$template" > "$imagemacct"
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
  local LDBSEARCH="$(which oss_ldapsearch)"
  local LDBMODIFY="$(which oss_ldapmodify)"
  # upload samba machine password hashes to host's machine account
  if [ -s "$imagemacct" ]; then
   echo "Machine account ldif file: $imagemacct"
   echo "Host: $compname"
   echo "Writing samba machine password hashes to ldap account:"
   sed -e "s|@@compname@@|$compname|" "$imagemacct" | "$LDAPMODIFY" -h localhost
  fi
}

#######################
# workstation related #
#######################
# extract ip address from ldap
get_ip() {
  unset RET
  local pattern="$1"
  RET=$(oss_ldapsearch "(&(objectClass=dhcpHost)(|(dhcpHWAddress=ethernet\\20$pattern)(cn=$pattern)))" | grep "dhcpStatements: fixed-address " | awk '{ print $3 }')
  return 0
}

# extract mac address from ldap
get_mac() {
  unset RET
  local pattern="$1"
  RET=$(oss_ldapsearch "(&(objectClass=dhcpHost)(|(dhcpStatements=fixed-address\\20$pattern)(cn=$pattern)))" | grep "dhcpHWAddress: ethernet " | awk '{ print $3 }')
  [ -n "$RET" ] && toupper "$RET"
  return 0
}

# extract hostname from ldap
get_hostname() {
  unset RET
  local pattern="$1"
  if validip "$pattern"; then
   RET="$(oss_ldapsearch "(&(objectclass=DHCPEntry)(aRecord=$pattern))" relativeDomainName | grep '^relativeDomainName: ' | awk '{ print $2 }')"
  elif validmac "$pattern"; then
   RET="$(oss_ldapsearch "(&(objectclass=SchoolWorkstation)(cn:dn:=Room72))" dhcpHWAddress | awk '(NR%3){ print p " " $0}{p=$0}' | awk '{ print $2 }' | sed -e 's@^cn=@@' -e 's@,.*@@')"
  else # assume hostname
   RET="$(oss_ldapsearch "(&(objectclass=DHCPEntry)(relativeDomainName=$pattern))" relativeDomainName | grep '^relativeDomainName: '| awk '{ print $2 }')"
  fi
  [ -n "$RET" ] && tolower "$RET"
  return 0
}

# get pxe flag: get_pxe ip|host
get_pxe() {
 local pattern="$1"
 local hw
 local res
 if validip "$pattern"; then
  pattern=get_hostname "$pattern"
 fi
 # assume hostname
 hw=$(oss_ldapsearch "(cn=$pattern)" | grep "configurationValue: HW=" | awk -F\= '{ print $2 }')
 res=$(oss_ldapsearch "(&(objectClass=SchoolConfiguration)(configurationValue=TYPE=HW)(description=$hw)(configurationValue=Imaging=linbo))")
 [ -n "$res" ] && res=1 || res=0
 echo "$res"
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

#################
# miscellanious #
#################

# test if string is in string
stringinstring() {
  case "$2" in *$1*) return 0;; esac
  return 1
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

# converting string to lower chars
toupper() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`echo $1 | tr a-z A-Z`
}

# get active groups
get_active_groups(){
  local actgroups="$(oss_ldapsearch "(&(objectClass=SchoolConfiguration)(configurationValue=TYPE=HW)(configurationValue=Imaging=linbo))" description | grep '^description: ' | awk '{ print $2 }'| sort -u)"
  echo "$actgroups"
}

# return active images
active_images() {
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
  local pxe="$(oss_ldapsearch "cn=$IP" dhcpOption | grep '^dhcpOption: extensions-path ' | awk '{ print $3 }')"
  [ -z "$pxe" ] && pxe="0"
  return "$pxe"
}

# get IPs from group
get_ips_from_group(){
  local GROUP="$1"
  local IP="$(oss_ldapsearch "(&(objectclass=SchoolWorkstation)(dhcpStatements=HW=$GROUP))" dhcpStatements | grep '^dhcpStatements: fixed-address ' | awk '{ print $3 }')"
  echo "$IP"
}

# get IPs from room
get_ips_from_room(){
  local ROOM="$1"
  local IP="$(oss_ldapsearch "(&(objectclass=SchoolWorkstation)(cn:dn:=$ROOM))" dhcpStatements | grep '^dhcpStatements: fixed-address ' | awk '{ print $3 }')"
  echo "$IP"
}
