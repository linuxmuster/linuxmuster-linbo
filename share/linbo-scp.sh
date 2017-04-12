#!/bin/bash
#
# linbo scp wrapper
#
# thomas@linuxmuster.net
# 20160916
# GPL V3
#

rsync -e linbo-ssh $@ ; RC="$?"

exit "$RC"

