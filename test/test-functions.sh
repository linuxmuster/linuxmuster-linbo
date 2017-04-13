#!/bin/bash
source /etc/linbo/linbo.conf
source $ENVDEFAULTS
source $HELPERFUNCTIONS

actgroups=$(get_active_groups)
echo "Gruppen: $actgroups"
