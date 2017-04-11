# linuxmuster shell helperfunctions
#
# thomas@linuxmuster.net
# 19.01.2016
# GPL v3
#

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# source network settings
[ -f "$NETWORKSETTINGS" ] && . $NETWORKSETTINGS

# lockfile
lockflag=/tmp/.linbo.lock

# date & time
[ -e /bin/date ] && DATETIME=`date +%y%m%d-%H%M%S`


####################
# common functions #
####################

# parse command line options
getopt() {
  until [ -z "$1" ]
  do
    if [ ${1:0:2} = "--" ]
    then
        tmp=${1:2}               # Strip off leading '--' . . .
        parameter=${tmp%%=*}     # Extract name.
        value=${tmp##*=}         # Extract value.
        eval $parameter=$value
#        [ -z "$parameter" ] && parameter=yes
    fi
    shift
  done
}

# cancel on error, $1 = Message, $2 logfile
cancel() {
  echo "$1"
  [ -e "$lockflag" ] && rm -f $lockflag
  [ -n "$2" ] && echo "$DATETIME: $1" >> $2
  exit 1
}

# check lockfiles, wait a minute whether it will be freed
checklock() {
  if [ -e "$lockflag" ]; then
    echo "Found lockfile $lockflag!"
    n=0
    while [ $n -lt $TIMEOUT ]; do
      remaining=$(($(($TIMEOUT-$n))*10))
      echo "Remaining $remaining seconds to wait ..."
      sleep 10
      if [ ! -e "$lockflag" ]; then
        touch $lockflag || return 1
        echo "Lockfile released!"
        return 0
      fi
      n=$(( $n + 1 ))
    done
    echo "Timed out! Exiting!"
    return 1
  else
    touch $lockflag || return 1
  fi
  return 0
}


# test if variable is an integer
isinteger () {
  [ $# -eq 1 ] || return 1

  case $1 in
  *[!0-9]*|"") return 1;;
            *) return 0;;
  esac
} # isinteger


# escape special characters
esc_spec_chars() {
	RET="$1"
	RET=${RET// /\\ }
	RET=${RET//(/\\(}
	RET=${RET//)/\\)}
	RET=${RET//$/\\$}
	RET=${RET//\!/\\!}
	RET=${RET//\&/\\&}
}


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

# check free space: check_free_space path size
check_free_space(){
	local cpath=$1
	local csize=$2
	echo -n "Pruefe freien Platz unter $cpath: " | tee -a $LOGFILE
	local available=`LANG=C df -P $cpath | grep -v Filesystem | awk '{ print $4 }' | tail -1`
	echo -n "${available}kb sind verfuegbar ... " | tee -a $LOGFILE
	if [ $available -ge $csize ]; then
		echo "Ok!" | tee -a $LOGFILE
		echo
		return 0
	else
		echo "zu wenig! Sie benoetigen mindestens ${csize}kb!" | tee -a $LOGFILE
		return 1
	fi
}

#######################
# config file editing #
#######################

addto_file() {
 # Parameter 1 original file
 # Parameter 2 changes file
 # Parameter 3 search pattern after that content of changes file will be inserted
 local ofile="$1"
 local cfile="$2"
 local pattern="$3"
 [ ! -s "$ofile" -o ! -s "$cfile" -o -z "$pattern" ] && return 1
 local tfile="/var/tmp/addto_file.$$"
 sed "N; /$pattern/r $cfile" <$ofile > $tfile || return 1
 cp $tfile $ofile
 rm $tfile
 return 0
}

removefrom_file() {
 # Parameter 1 original file
 # Parameter 2 begin search pattern e.g. "### linuxmuster - begin ###"
 # Parameter 3 end search pattern e.g. "### linuxmuster - end ###"
 local ofile="$1"
 local p_begin="$2"
 local p_end="$3"
 [ ! -s "$ofile" -o -z "$p_begin" -o -z "$p_end" ] && return 1
 local tfile="/var/tmp/removefrom_file.$$"
 sed "/$p_begin/,/$p_end/d" <$ofile > $tfile || return 1
 cp $tfile $ofile
 rm $tfile
 return 0
}

##########################
# check parameter values #
##########################

# check valid domain name
validdomain() {
 [ -z "$1" ] && return 1
 tolower "$1"
  if (expr match "$RET" '\([a-z0-9\-]\+\(\.[a-z0-9\-]\+\)\+$\)') &> /dev/null; then
    return 0
  else
    return 1
  fi
}

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


#######################
# workstation related #
#######################

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

# extract room ip address from file $WIMPORTDATA
get_room_ip() {
  unset RET
  [ -f "$WIMPORTDATA" ] || return 1
  local pattern="$1"
  RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $1 " " $5 }' | grep -i ^"$pattern " | tail -1 | awk '{ print $2 }'` &> /dev/null
  return 0
}

# extract mac address from file $WIMPORTDATA
get_mac() {
  unset RET
  [ -f "$WIMPORTDATA" ] || return 1
  local pattern="$1"
  if validip "$pattern"; then
   pattern="${pattern//./\\.}"
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $5 " " $4 }' | grep ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  else # assume hostname
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $2 " " $4 }' | grep -i ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  fi
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

# extract room from file $WIMPORTDATA
get_room() {
  unset RET
  [ -f "$WIMPORTDATA" ] || return 1
  local pattern="$1"
  if validip "$pattern"; then
   pattern="${1//./\\.}"
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $5 " " $1 }' | grep ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  elif validmac "$pattern"; then
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $4 " " $1 }' | grep -i ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  else # assume hostname
   RET=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $2 " " $1 }' | grep -i ^"$pattern " | awk '{ print $2 }'` &> /dev/null
  fi
  [ -n "$RET" ] && tolower "$RET"
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

# test if host is configured to pxe boot opsi: opsipxe ip|host
opsipxe() {
 local res="$(get_pxe "$1")"
 local i
 for i in $res; do
  isinteger "$i" || continue
  [ "$i" = "3" ] && return 0
 done
 return 1
}

# test if host is configured to pxe boot linbo: linbopxe ip|host
linbopxe() {
 local res="$(get_pxe "$1")"
 local i
 for i in $res; do
  isinteger "$i" || continue
  [ "$i" = "1" -o "$i" = "22" ] && return 0
 done
 return 1
}

# needed by internet & intranet on off scripts
# test valid mac, change hostname to mac, returns space separated list of macs
test_maclist() {
 local maclist="$1"
 local maclist_tested
 local mac_tested
 local m
 [ -z "$maclist" ] && return 1
 # parse maclist, change kommas to spaces
 maclist="$(echo $maclist | sed 's|,| |g')"
 for m in $maclist; do
  mac_tested=""
  # test if it is a macaddress otherwise assume it is a hostname
  if validmac "$m"; then
   mac_tested="$m"
  else
   get_mac "$m"
   [ -n "$RET" ] && mac_tested="$RET"
  fi
  if [ -n "$mac_tested" ]; then
   mac_tested="$(echo $mac_tested | tr a-z A-Z)"
   if [ -z "$maclist_tested" ]; then
    maclist_tested="$mac_tested"
   else
    maclist_tested="$maclist_tested $mac_tested"
   fi
  fi
 done
 
 echo "$maclist_tested"
 return 0
}

#################
# Firewall/OPSI #
#################

# test if firewall can be connected passwordless
test_pwless_ssh(){
 local ip="$1"
 local port="$2"
 local target="$3"
 if ! ssh -oNumberOfPasswordPrompts=0 -oStrictHostKeyChecking=no -p "$port" "$ip" echo "Passwordless ssh connection to $target is available."; then
  echo "Cannot establish ssh connection to $target!"
  return 1
 else
  return 0
 fi
}

# test if firewall can be connected passwordless
test_pwless_opsi(){
 if test_pwless_ssh "$opsiip" 22 OPSI; then
  return 0
 else
  return 1
 fi
}

# test if firewall can be connected passwordless
test_pwless_fw(){
 if test_pwless_ssh "$ipcopip" 222 Firewall; then
  return 0
 else
  return 1
 fi
}

# returns ipfire, ipcop or none
get_fwtype(){
 local fwtype="custom"
 ssh -p 222 root@$ipcopip /bin/ls /var/ipfire &> /dev/null && fwtype="ipfire"
 echo "$fwtype"
}

# check if urlfilter is active
check_urlfilter() {
 # get advanced proxy settings
 local fwtype="$(get_fwtype)"
 [ "$fwtype" != "ipfire" ] && cancel "Custom firewall is not supported!"
 get_ipcop /var/$fwtype/proxy/advanced/settings $CACHEDIR/proxy.advanced.settings || cancel "Cannot download proxy advanced settings!"
 . $CACHEDIR/proxy.advanced.settings || cancel "Cannot read $CACHEDIR/proxy.advanced.settings!"
 rm -f $CACHEDIR/proxy.advanced.settings
 [ "$ENABLE_FILTER" = "on" ] || return 1
 return 0
}

# execute a command on firewall
exec_ipcop() {
 # test connection
 ssh -p 222 root@$ipcopip $* &> /dev/null || return 1
 return 0
}

# execute a command on firewall width feedback
exec_ipcop_fb() {
  ssh -p 222 root@$ipcopip $*
}

# fetch file from firewall
get_ipcop() {
 scp -r -P 222 root@$ipcopip:$1 $2 &> /dev/null || return 1
 return 0
}

# upload file to firewall
put_ipcop() {
 scp -r -P 222 $1 root@$ipcopip:$2 &> /dev/null || return 1
 return 0
}

# create and upload custom networks file to firewall
fw_do_customnets(){
 rm -rf $FWCUSTOMNETWORKS
 touch $FWCUSTOMNETWORKS
 if [ "$subnetting" = "true" ]; then
  local line
  local network
  local netmask
  local netname
  local c=1
  grep ^[1-2] $SUBNETDATA | awk -F\; '{ print $1 }' | while read line; do
   netname="$(echo $line | awk -F\/ '{ print $1 }')"
   netmask="$(ipcalc -b $line | grep ^Netmask: | awk '{ print $2 }')"
   echo "$c,net $netname,$netname,$netmask,created by import_workstations" >> $FWCUSTOMNETWORKS
   c="$(( $c + 1 ))"
  done
 fi
 local RC=0
 put_ipcop $FWCUSTOMNETWORKS /var/ipfire/fwhosts/customnetworks.import || RC=1
 [ "$RC" = "1" ] && rm -rf $FWCUSTOMNETWORKS
 [ "$RC" = "0" ] && touch $FWCUSTOMNETWORKS
 return "$RC"
}

# create and upload custom hosts file to firewall
fw_do_customhosts(){
 rm -rf $FWCUSTOMHOSTS
 local RC=0
 grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F \; '{ print "#,host " $5 ",ip," $5 "," $2 }' | awk 'sub(/#/,++c)' > $FWCUSTOMHOSTS || RC=1
 ([ "$RC" = "0" ] && put_ipcop $FWCUSTOMHOSTS /var/ipfire/fwhosts) || RC=1
 ([ "$RC" = "0" ] && exec_ipcop chown nobody:nobody /var/ipfire/fwhosts/customhosts) || RC=1
 if [ "$RC" = "1" ]; then
  rm -rf $FWCUSTOMHOSTS
 else
  touch $FWCUSTOMHOSTS
 fi
 return "$RC"
}

# create and upload custom firewall stuff
fw_do_custom(){
 [ "$1" = "omit_hosts" ] && local omit_hosts="yes"
 # test if necessary dir is present
 exec_ipcop ls /var/ipfire/fwhosts || return 1
 if [ -z "$omit_hosts" ]; then
  fw_do_customhosts || return 1
 fi
 fw_do_customnets || return 1
}


#########################
# ip & subnetting stuff #
#########################

# print list of subnets which are allowed to access intranet
# get_allowed_subnets <intern|extern>
get_allowed_subnets() {
 case $1 in
  intern|extern) ;;
  *) return 0 ;;
 esac
 # senseless if internal firewall is deactivated
 if [ "$1" = "intern" ]; then
  . $DEFAULTCONF
  local active="$(echo "$START_LINUXMUSTER" | tr A-Z a-z)"
  [ "$active" = "yes" ] || return 0
 fi
 local subnetlist
 # get ranges from subnets
 for line in `sort -b -d -t';' -k1 $SUBNETDATA | grep ^[0-9]`; do
  if [ "$1" = "intern" ]; then
   local allowed="$(echo $line | awk -F\; '{ print $5 }')"
  else
   local allowed="$(echo $line | awk -F\; '{ print $6 }')"
  fi
  [ "$allowed" = "1" ] || continue
  local network="$(echo $line | awk -F\; '{ print $1 }')"
  if [ -z "$subnetlist" ]; then
   subnetlist="$network"
  else
   subnetlist="$subnetlist $network"
  fi
 done
 echo "$subnetlist"
}

# test if ip matches a subnet
# ipsubmatch <ip> <list of nets>
ipsubmatch(){
 local ip="$1"
 local netlist="$2"
 local netid
 local prefix
 local i
 for i in $netlist; do
  netid="$(echo $i | awk -F\/ '{ print $1}')"
  prefix="$(echo $i | awk -F\/ '{ print $2}')"
  [ -n "$netid" -a -n "$prefix" ] || continue
  local netid_test="$(ipcalc -b "$ip"/"$prefix" | grep ^Network | awk '{ print $2 }' | awk -F\/ '{ print $1 }')"
  [ "$netid_test" = "$netid" ] && return 0
 done
 return 1
}

# prints all ips of a subnet (from http://stackoverflow.com/questions/16986879/bash-script-to-list-all-ips-in-prefix)
# network_address_to_ips <netip/netmask>
network_address_to_ips() {
 [ -z "$1" ] && return 0
 local ips
 local network
 local iparr
 local netmaskarr
 local i
 local j
 local k
 local l
 # define empty array to hold the ip addresses
 ips=()
 # create array containing network address and subnet
 network=(${1//\// })
 # split network address by dot
 iparr=(${network[0]//./ })
 # check for subnet mask or create subnet mask from CIDR notation
 if [[ ${network[1]} =~ '.' ]]; then
  netmaskarr=(${network[1]//./ })
 else
  if [[ $((8-${network[1]})) > 0 ]]; then
   netmaskarr=($((256-2**(8-${network[1]}))) 0 0 0)
  elif  [[ $((16-${network[1]})) > 0 ]]; then
   netmaskarr=(255 $((256-2**(16-${network[1]}))) 0 0)
  elif  [[ $((24-${network[1]})) > 0 ]]; then
   netmaskarr=(255 255 $((256-2**(24-${network[1]}))) 0)
  elif [[ $((32-${network[1]})) > 0 ]]; then 
   netmaskarr=(255 255 255 $((256-2**(32-${network[1]}))))
  fi
 fi
 # correct wrong subnet masks (e.g. 240.192.255.0 to 255.255.255.0)
 [[ ${netmaskarr[2]} == 255 ]] && netmaskarr[1]=255
 [[ ${netmaskarr[1]} == 255 ]] && netmaskarr[0]=255
 # generate list of ip addresses
 for i in $(seq 0 $((255-${netmaskarr[0]}))); do
  for j in $(seq 0 $((255-${netmaskarr[1]}))); do
   for k in $(seq 0 $((255-${netmaskarr[2]}))); do
    for l in $(seq 1 $((255-${netmaskarr[3]}))); do
     ips+=( $(( $i+$(( ${iparr[0]}  & ${netmaskarr[0]})) ))"."$(( $j+$(( ${iparr[1]} & ${netmaskarr[1]})) ))"."$(($k+$(( ${iparr[2]} & ${netmaskarr[2]})) ))"."$(($l+$((${iparr[3]} & ${netmaskarr[3]})) )) )
    done
   done
  done
 done
 echo ${ips[@]}
}


#################
# nic setup     #
#################
discover_nics() {

 n=0
 # fetch all interfaces and their macs from /sys
 for i in /sys/class/net/bond* /sys/class/net/eth* /sys/class/net/br* /sys/class/net/wlan* /sys/class/net/intern /sys/class/net/extern /sys/class/net/dmz; do

  [ -e $i/address ] || continue

  iface[$n]="$(basename $i)"
  [ -z "${iface[$n]}" ] && continue

  address[$n]=`head -1 $i/address`
  [ `expr length ${address[$n]}` -eq 17 ] || continue

  toupper ${address[$n]}
  address[$n]=$RET
  id=`ls -1 -d $i/device/driver/0000:* 2> /dev/null`
  id=`echo $id | awk '{ print $1 }' -`
  id=${id#$i/device/driver/}
  id=${id#0000:}

  if [ -n "$id" ]; then
   tmodel=`lspci | grep $id | awk -F: '{ print $3 $4 }' -`
   tmodel=`expr "$tmodel" : '[[:space:]]*\(.*\)[[:space:]]*$'`
   tmodel=${tmodel// /_}
   model[$n]=${tmodel:0:38}
  else
   model[$n]="Unrecognized_Ethernet_Controller"
  fi

  n=$(( $n + 1 ))

 done

 nr_of_nics=$n

} # discover_nics


create_nic_choices() {

 n=0
 unset NIC_CHOICES
 while [ $n -lt $nr_of_nics ]; do
  menu[$n]="${iface[$n]} ${model[$n]} ${address[$n]}"
  if [ -n "$NIC_CHOICES" ]; then
   NIC_CHOICES="${NIC_CHOICES}, ${menu[$n]}"
  else
   NIC_CHOICES="${menu[$n]}"
  fi
  let n+=1
 done
 NIC_DEFAULT="${menu[0]}"
 NIC_CHOICES="$NIC_CHOICES, , Abbrechen"

} # create_nic_choices


assign_nics() {

 # first fetch all nics and macs from the system
 nr_of_nics=0
 discover_nics

 # no nic no fun
 if [ $nr_of_nics -lt 1 ]; then
  echo " Sorry, no NIC found! Aborting!"
  exit 1
 fi

 # substitute nicmenu descritpion
 NIC_DESC="Welche Netzwerkkarte ist mit dem internen Netz verbunden? \
           Wählen Sie die entsprechende Karte mit den Pfeiltasten aus \
           und starten Sie dann die Serverkonfiguration mit ENTER."
 db_subst linuxmuster-base/nicmenu nic_desc $NIC_DESC

 # compute menu entries
 create_nic_choices

 # build menu
 db_fset linuxmuster-base/nicmenu seen false
 db_subst linuxmuster-base/nicmenu nic_choices $NIC_CHOICES

 # menu input
 db_set linuxmuster-base/nicmenu $NIC_DEFAULT || true
 db_input $PRIORITY linuxmuster-base/nicmenu || true
 db_go
 db_get linuxmuster-base/nicmenu || true
 iface_lan="$(echo "$RET" | awk '{ print $1 }')"

 [ "$iface_lan" = "Abbrechen" ] && exit 1

 db_set linuxmuster-base/iface_lan $iface_lan || true
 db_go

 # write iface to network.settings
 if [ -e "$NETWORKSETTINGS" ]; then
  if grep -q ^iface_lan $NETWORKSETTINGS; then
   sed -e "s|^iface_lan=.*|iface_lan=$iface_lan|" -i $NETWORKSETTINGS
  else
   echo "iface_lan=$iface_lan" >> $NETWORKSETTINGS
  fi
 fi

} # assign_nics


########
# ldap #
########

# get login by id
# uid=$1
get_login_by_id() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select uid from userdata where id = '$1';"`
}

# get uid number for user
# username=$1
get_uidnumber() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select uidnumber from posix_account where uid = '$1';"`
}

# get group number for group name
# group=$1
get_gidnumber() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select gidnumber from groups where gid = '$1';"`
}

# get user's primary group
# username=$1
get_pgroup() {
  unset T_RET
  unset RET
  [ -z "$1" ] && return 1
  T_RET=`psql -U ldap -d ldap -t -c "select gidnumber from posix_account where uid = '$1';"`
  [ -z "$T_RET" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select gid from groups where gidnumber = '$T_RET';"`
}

# get homedir for user
# username=$1
get_homedir() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select homedirectory from posix_account where uid = '$1';"`
}

# get realname for user
# username=$1
get_realname() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select gecos from posix_account where uid = '$1';"`
}

# get primary group members from ldab db
# group=$1
get_pgroup_members() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select uid from memberdata where adminclass = '$1';"`
}

# get all group members from ldab db
# group=$1
get_group_members() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select uid from memberdata where adminclass = '$1' or gid = '$1';"`
}

# check if group is a project
# group=$1
check_project() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select gid from projectdata where gid = '$1';"`
  strip_spaces $RET
  [ "$RET" = "$1" ] && return 0
  return 1
}

# check for valid group, group members and if teacher is set, for teacher membership
# group=$1, teacher=$2
check_group() {
  # check valid gid
  unset RET
  [ -z "$1" ] && return 1

  get_gidnumber $1
  [ -z "$RET" ] && return 1
  [ "$RET" -lt 10000 ] && return 1

  # fetch group members to $RET, return 1 if there are no members
  unset RET
  get_group_members $1 || return 1
  [ -z "$RET" ] && return 1

  # check if teacher is in group
  if [ -n "$2" ]; then
    if ! echo "$RET" | grep -qw $2; then
      return 1
    fi
  fi

  return 0
}

# get all host accounts from db
hosts_db() {
  local RET
  RET=`psql -U ldap -d ldap -t -c "select uid from posix_account where firstname = 'Exam';"`
  if [ -n "$RET" ]; then
	 	echo "$RET" | awk '{ print $1 }'
   return 0
  else
   return 1
  fi
}

# get all host accounts from ldap
hosts_ldap() {
  local RET
  RET=`ldapsearch -x -h localhost "(description=ExamAccount)" | grep ^uid\: | awk '{ print $2 }'`
  if [ -n "$RET" ]; then
		echo "$RET"
    return 0
  else
    return 1
  fi
}

# get all host accounts
machines_db() {
  local RET
  RET=`psql -U ldap -d ldap -t -c "select uid from posix_account where firstname = 'Computer';"`
  if [ -n "$RET" ]; then
		 echo "$RET" | awk '{ print $1 }'
   return 0
  else
   return 1
  fi
}

# get all host accounts from ldap
machines_ldap() {
  local RET
  RET=`ldapsearch -x -h localhost "(gidNumber=515)" | grep ^uid\: | awk '{ print $2 }'`
  if [ -n "$RET" ]; then
		echo "$RET"
    return 0
  else
    return 1
  fi
}

# get all user accounts
accounts_db() {
  local RET
  RET=`psql -U ldap -d ldap -t -c "select uid from posix_account where firstname <> 'Computer' and firstname <> 'Exam';"`
  if [ -n "$RET" ]; then
		 echo "$RET" | awk '{ print $1 }'
   return 0
  else
   return 1
  fi
}

# get all user accounts from ldap
accounts_ldap() {
  local RET
  RET=`ldapsearch -x -h localhost "(&(!(gidNumber=515))(!(description=ExamAccount)))" | grep ^uid\: | awk '{ print $2 }'`
  if [ -n "$RET" ]; then
		echo "$RET"
    return 0
  else
    return 1
  fi
}

# check if account exists
# username=$1
check_id() {
  unset RET
  [ -z "$1" ] && return 1
  RET=`psql -U ldap -d ldap -t -c "select uid from posix_account where uid = '$1';"`
  if [ -n "$RET" ]; then
    return 0
  else
    return 1
  fi
}

# check if user is teacher
# teacher=$1
check_teacher() {
  [ -z "$1" ] && return 1
  groups "$1" | grep -qw "$TEACHERSGROUP" && return 0
  return 1
}

# check if user is admin
# admin=$1
check_admin() {
 [ -z "$1" ] && return 1
 groups "$1" | grep -qw "$DOMADMINS" && return 0
 return 1
}


#################
# miscellanious #
#################

# stripping trailing and leading spaces
strip_spaces() {
  unset RET
  RET=`expr "$1" : '[[:space:]]*\(.*\)[[:space:]]*$'`
  return 0
}

# test if string is in string
stringinstring() {
  case "$2" in *$1*) return 0;; esac
  return 1
}

# checking if directory is empty, in that case it returns 0
check_empty_dir() {
  unset RET
  RET=$(ls -A1 $1 2>/dev/null | wc -l)
  [ "$RET" = "0" ] && return 0
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
