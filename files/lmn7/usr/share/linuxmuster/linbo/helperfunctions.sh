#
# helperfunctions for linbo scripts
#
# thomas@linuxmuster.net
# 20190314
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

# check valid domain name
validdomain() {
 [ -z "$1" ] && return 1
  if (expr match "$1" '\([A-Za-z0-9\-]\+\(\.[A-Za-z0-9\-]\+\)\+$\)') &> /dev/null; then
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

# return hostgroup of device from devices.csv
get_hostgroup(){
  local clientname="$(echo "$1" | tr A-Z a-z)"
  grep -v ^# "$WIMPORTDATA" | grep -w "$clientname" | awk -F\; '{ print $2 " " $3 }'  | grep -w "$clientname" | awk '{ print $2 }'
}

# return active images
active_images() {
 # check for workstation data
 [ -z "$WIMPORTDATA" ] && return 1
 [ -s "$WIMPORTDATA" ] || return 1
 # get active groups
 local actgroups="$(grep ^[-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789] $WIMPORTDATA | awk -F\; '{ print $3 }' | sort -u)"
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

# check torrent against image
check_torrent() {
 local image="$1"
 local torrent="$image.torrent"
 cd "$LINBODIR"
 # in case of directory creation of torrent file will be forced
 [ -d "$image" ] && return 1
 [ -s "$image" ] || return 1
 [ -s "$torrent" ] || return 1
 local tmpfile=/var/tmp/check_torrent.$$
 btshowmetainfo "$torrent" > $tmpfile || return 1
 local filename="$(grep ^"file name" $tmpfile | awk '{ print $3 }')"
 local filesize="$(grep ^"file size" $tmpfile | awk '{ print $3 }')"
 rm $tmpfile
 [ "$filename" = "$(basename $image)" ] || return 1
 local imagesize="$(ls -l $image | awk '{ print $5 }')"
 [ "$filesize" = "$imagesize" ] || return 1
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
