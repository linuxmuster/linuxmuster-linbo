#
# helperfunctions for linbo scripts
#
# thomas@linuxmuster.net
# 22.03.2015
#

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
