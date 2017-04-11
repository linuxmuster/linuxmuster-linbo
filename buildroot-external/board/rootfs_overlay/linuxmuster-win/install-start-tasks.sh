#!/bin/sh
#
# install-start-tasks.sh
# installs tasks which were executed on windows boot
# invoked by linbo_cmd start()
#
# thomas@linuxmuster.net
# 23.10.2015
#

# test if already installed
outdir="$(ls -d /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Tt][Aa][Ss][Kk][Ss] 2> /dev/null)"
[ -d "$outdir" ] || exit 0
taskfilename="$outdir/linuxmuster-start-tasks"
[ -s "$taskfilename" ] && exit 0

# get hive
hive="$(ls /mnt/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2> /dev/null)"
[ -s "$hive" ] || exit 0

echo "Installiere linuxmuster-start-tasks:"

# get hive keys with used task uuids
echo -n " * Exportiere Tasks ... "
outreg="/tmp/tasks.reg"
if reged -x "$hive" HKEY_LOCAL_MACHINE\\SOFTWARE "Microsoft\\Windows NT\\CurrentVersion\\Schedule\\TaskCache\\Tasks" "$outreg" >> /tmp/linbo.log; then
 echo "OK!"
else
 echo "Fehler!"  >&2
 exit 1
fi
# test for unused uuid
echo -n " * Ermittle Task-UUID ... "
while true; do
 uuid="$(uuidgen | tr a-z A-Z)"
 [ -z "$uuid" ] && break
 grep -q "$uuid" "$outreg" || break
done
if [ -n "$uuid" ]; then
 echo "OK!"
else
 echo "Fehler!"  >&2
 exit 1
fi

# create registry file from template
echo -n " * Erstelle Registry-Patch ... "
template="/linuxmuster-win/start-tasks.reg.tpl"
if sed -e "s|@@uuid@@|$uuid|g" "$template" > "$outreg"; then
 echo "OK!"
else
 echo "Fehler!"  >&2
 exit 1
fi

# patch registry
echo -n " * Wende Registry-Patch an ... "
if reged -C -I "$hive" HKEY_LOCAL_MACHINE\\SOFTWARE "$outreg" | grep -iqw "OK"; then
 echo "OK!"
else
 echo "Fehler!"  >&2
 exit 1
fi

# copy taskfile in place
echo -n " * Kopiere Taskdatei ... "
template="/cache/linuxmuster-win/start-tasks.xml"
if cp "$template" "$taskfilename"; then
 echo "OK!"
else
 echo "Fehler!"  >&2
 exit 1
fi

echo "Fertig!"

exit 0

