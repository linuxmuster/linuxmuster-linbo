#!/bin/bash

error(){
 echo "$1"
 exit 1
}

[ -n "$LINBODIR" ] || error "LINBODIR not set."
[ -n "$INTERFACE" ] || error "INTERFACE not set."
[ -n "$LOGFILE" ] || error "LOGFILE not set."
[ -n "$MINCLIENTS" ] || error "MINCLIENTS not set."
[ -n "$MINSECONDS" ] || error "MINSECONDS not set."
[ -n "$MAXSECONDS" ] || error "MAXSECONDS not set."

cd "$LINBODIR" || exit 1

while read file serverport relax; do
 port="${serverport##*:}"
 if [ -s "$file" ]; then
  echo "Starte udp-sender $file -> $INTERFACE:$port" >&2
  while true; do
   udp-sender --full-duplex --interface "$INTERFACE" --portbase $port --min-clients $MINCLIENTS --min-wait $MINSECONDS --max-wait $MAXSECONDS --log $LOGFILE --file "$file" --nokbd || exit 1
  done &
 fi
done < multicast.list
