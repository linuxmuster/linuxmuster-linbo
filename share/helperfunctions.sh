
# check if image is in use
image_in_use() {
 local image="$(basename $1)"
 local configs="$(grep -H $image $LINBODIR/start.conf.* | grep -v \:# | awk -F\: '{ print $1 }')"
 # check if image is defined in start.conf
 [ -z "$configs" ] && return 1
 local i=""
 local g=""
 local ret=""
 for i in $configs; do
  # check if any group is defined in workstations
  g="$(basename $i)"
  g="${g#start.conf.}"
  ret="$(grep \;$g\; $WIMPORTDATA | grep -v ^# | awk -F\; '{ print $3 }')"
  [ -n "$ret" ] && return 0
 done
 return 1
}

# create torrent file for image
create_torrent() {
 local image="$1"
 local RC=1
 [ -s "$image" ] || return "$RC"
 local serverip="$2"
 local port="$3"
 echo "Creating $image.torrent ..."
 btmakemetafile "$image" http://${serverip}:${port}/announce ; RC="$?"
 return "$RC"
}

