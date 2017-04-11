#!/bin/bash
#
# linbo scp wrapper
#
# Thomas Schmitt <schmitt@lmz-bw.de>
#
# GPL V3
#
# last change: 08.12.2009
#

rsync -e linbo-ssh $@ ; RC="$?"

exit "$RC"

