#
# helperfunctions for linbo scripts
#
# thomas@linuxmuster.net
# 20170213
#

source /etc/linbo/linbo.conf
source $LINBOSHAREDIR/${FLAVOUR}helperfunctions.sh

# check valid domain name
validdomain() {
 [ -z "$1" ] && return 1
  if (expr match "$1" '\([A-Za-z0-9\-]\+\(\.[A-Za-z0-9\-]\+\)\+$\)') &> /dev/null; then
    return 0
  else
    return 1
  fi
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
