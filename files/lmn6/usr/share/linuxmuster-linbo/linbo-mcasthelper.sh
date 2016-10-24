#!/bin/sh
#
# schmitt@lmz-bw.de
# GPL v3
# $Id: linbo-mcasthelper.sh 1089 2011-06-08 18:48:24Z tschmitt $
#
# linbo multicast helper script, started in a screen session by init script
#

INTERFACE="$1"
PORT="$2"
MINCLIENTS="$3"
MINSECONDS="$4"
MAXSECONDS="$5"
FILE="$6"
LOGFILE="$7"

while true; do
 echo >> "$LOGFILE"
 echo "### Starting new session: `date`" | tee -a "$LOGFILE"
 echo "Watch output in $LOGFILE."
 udp-sender --full-duplex --interface "$INTERFACE" --portbase $PORT --min-clients $MINCLIENTS --min-wait $MINSECONDS --max-wait $MAXSECONDS --file "$FILE" --nokbd 2>> "$LOGFILE" 1>> "$LOGFILE" ; RC="$?"
 [ "$RC" = "0" ] || exit "$RC"
done

