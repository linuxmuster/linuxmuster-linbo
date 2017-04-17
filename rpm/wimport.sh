# workstation import for linuxmuster.net
#
# Thomas Schmitt <thomas@linuxmuster.net>
# 13.06.2016
# GPL v3
#
# adapted for oss-linbo
# Frank Schütte <fschuett@gymhim.de>
# 17.03.2017
# workstations file (oss)
# raum;rechner;gruppe;mac;;;;;;;linbo=1;

RC=0


### functions begin ###

# check for unique entry: check_unique <item1 item2 ...>
check_unique() {
 printf '%s\n' $1 | sort | uniq -c -d
}


# cancel with message
exitmsg() {
 echo "  > $1"
 echo
 echo "An error ocurred and import_workstations will be cancelled!"
 echo "No modifications have been made to your system!"
 rm -f $locker
 RC=1
 echo
 exit $RC
}


# sets serverip in start.conf
set_serverip(){
 local conf="$LINBODIR/start.conf.$1"
 local serverip="$2"
 local RC="0"
 grep -qi ^"server = $serverip" $conf && return "$RC"
 if grep -qwi ^server $conf; then
  sed -e "s/^[Ss][Ee][Rr][Vv][Ee][Rr].*/Server = $serverip/" -i $conf || RC="1"
 else
  sed -e "/^\[LINBO\]/a\
Server = $serverip" -i $conf || RC="1"
 fi
 return "$RC"
}


# sets group in start.conf
set_group(){
 local group="$1"
 local conf="$LINBODIR/start.conf.$group"
 local RC="0"
 grep -qi ^"Group = $group" $conf && return "$RC"
 if grep -qwi ^group $conf; then
  sed -e "s/^[Gg][Rr][Oo][Uu][Pp].*/Group = $group/" -i $conf || RC="1"
 else
  sed -e "/^Server/a\
Group = $group" -i $conf || RC="1"
 fi
 return "$RC"
}

# get systemtype from start.conf
get_systemtype(){
 local group="$1"
 local conf="$LINBODIR/start.conf.$group"
 [ -e "$conf" ] || return 1
 grep -iw ^systemtype "$conf" | tail -1 | awk -F\= '{ print $2 }' | awk '{ print $1 }'
}

# compute and print grub2 compliant disk name
# args: partition
grubdisk(){
 local partition="$1"
 local partnr="$(echo "$partition" | sed -e 's|/dev/[hsv]d[abcdefgh]||' -e 's|/dev/xvd[abcdefgh]||' -e 's|/dev/mmcblk[0-9]p||')"
 case "$partition" in
  /dev/mmcblk*) local disknr="$(echo "$partition" | sed 's|/dev/mmcblk\([0-9]\)p[1-9]|\1|')" ;;
  *:*|*//*|*\\\\*) echo "nocache" ; return 0 ;; # remote cache, no local cache, no cache partition
  *)
   local ord="$(printf "$(echo $partition | sed 's|/dev/*[hsv]d\([a-z]\)[0-9]|\1|')" | od -A n -t d1)"
   local disknr=$(( $ord - 97 ))
   ;;
 esac
 echo "(hd${disknr},${partnr})"
}

# sets pxe config file, params: group kopts
set_pxeconfig(){
 local group="$1"
 local kopts="$2"
 local RC="0"
 local startconf="$LINBODIR/start.conf.$group"
 local targetconf="$LINBODIR/boot/grub/$group.cfg"
 local globaltpl="$LINBOTPLDIR/grub.cfg.global"
 local cache="$(grep -i ^cache /$startconf | tail -1 | awk -F\= '{ print $2 }' | awk '{ print $1 }' 2> /dev/null)"
 local cacheroot="$(grubdisk "$cache" "$group")"
 local ostpl
 local ostype
 if ([ -s "$targetconf" ] && ! grep -q "$MANAGEDSTR" "$targetconf"); then
  echo -e "\tkeeping pxe config."
  return 0
 fi

 # create gobal part for group cfg
 echo -e "\twriting pxe config."
 sed -e "s|@@group@@|$group|g
         s|@@cacheroot@@|$cacheroot|g
         s|@@kopts@@|$kopts|g" "$globaltpl" > "$targetconf" || RC="1"

 # collect boot parameters from start.conf and write os parts for group cfg
 local line
 local partnr
 local root
 local name
 local osroot
 local kernel
 local initrd
 local append
 local ostpl="$LINBOTPLDIR/grub.cfg.os"
 local osnr=0
 echo "[EOF]" | cat "$startconf" - | grep -v '^$\|^\s*\#' | awk -F\# '{ print $1 }' | sed -e 's|^ *||g' -e 's| *$||g' -e 's| =|=|g' -e 's|= |=|g' | while read line; do
  if [ "${line:0:1}" = "[" ]; then
   if [ -n "$kernel" ]; then
    osnr=$((osnr + 1))
    if [ "$kernel" = "reboot" ]; then
     kernel="nokernel_placeholder"
    else
     kernel="$(echo $kernel | sed 's|^\/||')"
    fi
    if [ -z "$initrd" ]; then
     initrd="noinitrd_placeholder"
    else
     initrd="$(echo $initrd | sed 's|^\/||')"
    fi
    # convert partition to grub syntax
    osroot="$(grubdisk "$root" "$group")"
    # computer partition number from start.conf
    partnr="$(grep -i ^dev "$startconf" | grep -n "$root" | awk -F\: '{ print $1 }')"
    # get ostype from osname
    case "$(echo "$name" | tr A-Z a-z)" in
     *windows*) ostype="win" ;;
     *kubuntu*) ostype="kubuntu" ;;
     *lubuntu*) ostype="lubuntu" ;;
     *xubuntu*) ostype="xubuntu" ;;
     *ubuntu*|*trusty*|*wily*) ostype="ubuntu" ;;
     *centos*) ostype="centos" ;;
     *arch*) ostype="arch" ;;
     *linuxmint*) ostype="linuxmint" ;;
     *fedora*) ostype="fedora" ;;
     *gentoo*) ostype="gentoo" ;;
     *debian*) ostype="debian" ;;
     *suse*) ostype="opensuse" ;;
     *linux*) ostype="linux" ;;
     *) ostype="unknown" ;;
    esac
    # create config from template
    sed -e "s|@@osnr@@|$osnr|g
            s|@@kernel@@|$kernel|g
            s|@@initrd@@|$initrd|g
            s|@@append@@|$append|g
            s|@@partition@@|$root|g
            s|@@partnr@@|$partnr|g
            s|@@osroot@@|$osroot|g
            s|@@osname@@|$name|g
            s|@@ostype@@|$ostype|g
            s|@@group@@|$group|g
            s|@@cacheroot@@|$cacheroot|g
            s|@@kopts@@|$kopts|g" "$ostpl" >> "$targetconf" || RC="1"
   fi
   name=""; root=""; kernel=""; initrd=""; append=""; osroot=""; ostype=""
   continue
  fi
  case "$line" in
   [Nn][Aa][Mm][Ee]=*) name="$(echo $line | awk -F\= '{ print $2 }')" ;;
   [Aa][Pp][Pp][Ee][Nn][Dd]=*) append="$(echo $line | sed s'|^[Aa][Pp][Pp][Ee][Nn][Dd]=||')" ;;
   [Rr][Oo][Oo][Tt]=*|[Kk][Ee][Rr][Nn][Ee][Ll]=*|[Ii][Nn][Ii][Tt][Rr][Dd]=*) eval "$(echo $line | tr A-Z a-z)" ;;
  esac
 done

 return "$RC"
}


# process configs for pxe hosts
do_pxe(){
 local group="$1"
 local ip="$2"
 local RC="0"
 local server=""
 local kopts=""
 # copy default start.conf if there is none for this group
 if [ ! -e "$LINBODIR/start.conf.$group" ]; then
  echo "    Creating new linbo group $group."
  cp "$LINBODEFAULTCONF" "$LINBODIR/start.conf.$group" || RC="2"
 fi

 # process start.conf and pxelinux configfile for group
 if ! echo "$groups_processed" | grep -qwi "#${group}#"; then
  echo -en " * LINBO-Group\t$group"
  groups_processed="$groups_processed #${group}#"
  # get kernel options from start.conf
  kopts="$(linbo_kopts "$LINBODIR/start.conf.$group")"
  # get custom serverip from kernel opts if set
  if echo "$kopts" | grep -qw server; then
   for i in $kopts; do eval "$i" &> /dev/null; done
  fi
  # set custom server ip in start.conf if defined in kernel opts
  if validip "$server"; then
   set_serverip "$group" "$server" || RC="2"
  else # set default server ip
   set_serverip "$group" "$serverip" || RC="2"
  fi
  # set group in start.conf
  set_group "$group" || RC="2"
  # provide grub2 pxe configfile for group
  set_pxeconfig "$group" "$kopts" || RC="2"
 fi

 case "$RC" in
  1) echo "   ERROR in pxe host configuration!" ;;
  2) echo "   ERROR in pxe group configuration!" ;;
  *) ;;
 esac
 return "$RC"
}

### functions end ###


# adding new host entries from LINBO's registration
if ls $LINBODIR/*.new &> /dev/null; then
 for i in $LINBODIR/*.new; do
  if [ -s "$i" ]; then
   hostname="$(basename "$i" | sed 's|.new||')"
   echo "Importing new host $hostname:"
   cat $i
   echo
   cat $i >> $WIMPORTDATA
  fi
  rm -f $i
 done
fi


# case repair for workstation data
# all to lower case, macs to upper case
sed -e 's/\(^[A-Za-z0-9].*\)/\L\1/
        s/\([a-fA-F0-9]\{2\}[:][a-fA-F0-9]\{2\}[:][a-fA-F0-9]\{2\}[:][a-fA-F0-9]\{2\}[:][a-fA-F0-9]\{2\}[:][a-fA-F0-9]\{2\}\)/\U\1/g' -i "$WIMPORTDATA"


# check workstation data
echo "Checking workstation data ..."
echo -n " - checking rooms..."
# rooms
rooms="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print $1 }' | sort -u)"
for i in $rooms; do
 check_string "$i" || exitmsg "$i is no valid room name!"
done
echo "done."

echo -n " - checking hostgroups..."
# hostgroups
hostgroups="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print "#"$3"#" }' | sort -u)"
echo "$hostgroups" | grep -q "##" && exitmsg "Empty hostgroup found! Check your data!"
hostgroups="${hostgroups//#/}"
for i in $hostgroups; do
 check_string "$i" || exitmsg "$i is no valid hostgroup name!"
done
echo "done."

echo -n " - checking hostnames..."
# hostnames, one host can have two entries with different macs (wired and wlan)
hostnames="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print "#"$2"#" }')"
echo "$hostnames" | grep -q "##" && exitmsg "Empty hostname found! Check your data!"
hostnames="${hostnames//#/}"
for i in $hostnames; do
 validhostname "$i" || exitmsg "$i is no valid hostname!"
done
check_unique "$hostnames" | while read line; do
 i="$(echo $line | awk '{ print $2 }')"
 # check ips for hostname
 get_ip "$i"
 [ -n "$(check_unique "$RET")" ] && exitmsg "Ips for host $i are not unique: $RET!"
 # check macs for hostname
 get_mac "$i"
 [ -n "$(check_unique "$RET")" ] && exitmsg "Macs for host $i are not unique: $RET!"
done
echo "done."

echo -n " - checking macs..."
# macs
macs="$(grep ^[a-zA-Z0-9] $WIMPORTDATA | awk -F\; '{ print "#"$4"#" }')"
echo "$macs" | grep -q "##" && exitmsg "Empty mac address found! Check your data!"
macs="${macs//#/}"
for i in $macs; do
 validmac "$i" || exitmsg "$i is no valid mac address!"
done
RET="$(check_unique "$macs")"
[ -n "$RET" ] && exitmsg "Not unique mac(s) detected: $RET!"
echo "done."

# tests are done
echo " Ok!"
echo

# sync host accounts
echo "Creating new workstations accounts..."
oss_workstations_sync_hosts.pl<$WIMPORTDATA 2>> $TMPLOG

if [ "$RC" = "0" ]; then
 echo "Done!"
 echo
 # restart nameserver
 service named reload
else
 echo "oss_workstations_sync_hosts.pl exits with error!"
 echo
 rm -f $locker
 exit "$RC"
fi # sync host accounts

echo "Creating/modifying PXE/DHCP entries..."
tmpdhcp="/tmp/modify_dhcpstatements.$$"
rm -f $tmpdhcp
groups_processed=""
sort -b -d -t';' -k5 $WIMPORTDATA | grep ^[a-z0-9] | while read line; do

 # get data from line
 room="$(echo "$line" | awk -F\; '{ print $1 }')"
 hostname="$(echo "$line" | awk -F\; '{ print $2 }')"
 hostgroup="$(echo "$line" | awk -F\; '{ print $3 }')"
 hostgroup="$(echo "$hostgroup" | awk -F\, '{ print $1 }')"
 ip="$(host $hostname | sed 's/.* //g')"
 mac="$(echo "$line" | awk -F\; '{ print $4 }')"
 pxe="$(echo "$line" | awk -F\; '{ print $11 }')"

 # create dhcpd entries for hosts in ldap
 case "$pxe" in
  1|2|3|22)
   # determine systemtype for efi netboot
   systemtype="$(get_systemtype "$hostgroup")"
   # process linbo pxe configs
   do_pxe "$hostgroup" || RC="1"
   if [ -n "$RC" ]; then
     cat >>$tmpdhcp <<EOF
name $hostname
group $hostgroup
ipaddress $ip
systemtype $systemtype
EOF
   fi
   echo -en " * PXE" ;;
  *) echo -en " * IP" ;;
 esac
 echo -e "-Host\t$hostname."

done
echo "Done!"
echo

echo "Writing DHCP statements to LDAP...";
# write dhcpd entries to ldap
if [ -e "$tmpdhcp" ]; then
    oss_modify_dhcpStatements.pl <$tmpdhcp || RC="1"
else
    echo "  * No DHCP statements to write to LDAP";
fi
echo "Done!"
echo
rm -f $tmpdhcp

# exit with return code
exit $RC

