#!/bin/bash
#
# linbo ssh wrapper
#
# thomas@linuxmuster.net
# 20160916
# GPL V3
#

# read linuxmuster environment
source /etc/linbo/linbo.conf
source $ENVDEFAULTS || exit 1

if [ "$FLAVOUR" = "lmn7" ]; then
  SSH_CONFIG="$SYSDIR/linbo/ssh_config"
else
  SSH_CONFIG="$SYSCONFDIR/linbo/ssh_config"
fi

ssh -F $SSH_CONFIG $@ ; RC="$?"

exit "$RC"

