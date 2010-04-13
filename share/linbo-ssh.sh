#!/bin/bash
#
# linbo ssh wrapper
#
# Thomas Schmitt <schmitt@lmz-bw.de>
#
# GPL V3
#
# last change: 08.12.2009
#

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1

SSH_CONFIG="$SYSCONFDIR/linbo/ssh_config"

ssh -F $SSH_CONFIG $@ ; RC="$?"

exit "$RC"

