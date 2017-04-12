#
# lmn7 helperfunctions for linbo scripts
#
# thomas@linuxmuster.net
# 20170213
#

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
   RET=`grep -v ^# $WIMPORTDATA awk -F\; '{ print $4 " " $2 }' | grep -i ^"$pattern " | awk '{ print $2 }'` &> /dev/null
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
  return 0
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
  return 0
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
  return "$compname"
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
   if [ -n "$unicodepwd" ]; then
    echo "Writing samba password hash file for image $image."
    template="$LINBOTPLDIR/machineacct"
    imagemacct="$LINBODIR/$image.macct"
    sed -e "s|@@unicodepwd@@|$unicodepwd|" "$template" > "$imagemacct"
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
