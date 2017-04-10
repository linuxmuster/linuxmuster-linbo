#!/bin/bash
#
# linbo ssh wrapper
#
# thomas@linuxmuster.net
# 20160916
# GPL V3
#

# read linuxmuster environment
source /usr/share/linuxmuster/defaults.sh || exit 1

SSH_CONFIG="$SYSDIR/linbo/ssh_config"

ssh -F $SSH_CONFIG $@ ; RC="$?"

exit "$RC"

