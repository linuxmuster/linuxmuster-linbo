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
