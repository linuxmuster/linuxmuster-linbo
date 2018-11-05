#!/bin/bash
# linbo-restore-vlan-links.sh
# call /srv/tftp/pxelinux.cfg/vlan.sh if existing
#
if [ -d /srv/tftp/pxelinux.cfg ]; then
  (
  cd /srv/tftp/pxelinux.cfg
  [ -x ./vlan.sh ] && ./vlan.sh
  )
fi
