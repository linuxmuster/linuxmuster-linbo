#!/bin/bash
#
# creating/updating group specific linbofs.gz
#
# Thomas Schmitt <schmitt@lmz-bw.de>
# GPL V3
# $Id: update-linbofs.sh 1083 2011-06-07 10:13:34Z tschmitt $

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

groups="$@"

# sets serverip in start.conf
set_serverip(){
 local conf=$1
 grep -q ^"Server = $serverip" $conf && return 0
 if grep -q ^Server $conf; then
  sed -e "s/^Server.*/Server = $serverip/" -i $conf
 else
  sed -e "/^\[LINBO\]/a\
Server = $serverip" -i $conf
 fi
}

# sets group in start.conf
set_group(){
 local conf=$1
 local group=$2
 grep -q ^"Group = $group" $conf && return 0
 if grep -q ^Group $conf; then
  sed -e "s/^Group.*/Group = $group/" -i $conf
 else
  sed -e "/^Server/a\
Group = $group" -i $conf
 fi
}

# sets pxe config file
set_pxeconfig(){
 local group=$1
 local conf="$LINBODIR/pxelinux.cfg/$group"
 if [ -e "$conf" ]; then
  sed -e "s|initrd=linbofs[.a-zA-Z0-9_-]*.gz|initrd=linbofs.gz|g" -i $conf
 else
  # copy default pxelinux config for group
  cp $PXELINUXCFG $conf
  if grep -i ^kernel $LINBODIR/start.conf.$group | grep -qiw reboot; then
   # sets default boot method for reboot workaround
   grep -q ^"LABEL reboot" $conf && sed -e 's|^DEFAULT .*|DEFAULT reboot|' -i $conf
  fi
 fi
}

# check & set lockfile
locker=/tmp/.update-linbofs.lock
if [ -e "$locker" ]; then
	echo "Caution! Probably there is another update-linbofs process running!"
	echo "If this is not the case you can safely remove the lockfile $locker"
	echo "and give update-linbofs another try."
	echo "update-linbofs is locked! Exiting!"
	exit 1
fi
touch $locker || exit 1
chmod 400 $locker
curdir=`pwd`
tmpdir="/var/tmp/linbofs.$$"
[ -e "$tmpdir" ] && rm -rf $tmpdir

# clean tmpdir and exit with error
bailout() {
 echo "$1"
 cd "$curdir"
 [ -n "$tmpdir" -a -e "$tmpdir" ] && rm -rf $tmpdir
 [ -n "$locker" -a -e "$locker" ] && rm -f $locker
 exit 1
}

# this script makes only sense if imaging=linbo
[ "$imaging" != "linbo" ] && bailout "Imaging system is $imaging and not linbo!"

# check for default linbofs.gz
[ ! -s "$LINBODIR/linbofs.gz" ] && bailout "Error: $LINBODIR/linbofs.gz not found!"

# grep linbo rsync password to sync it with linbo account
[ ! -s /etc/rsyncd.secrets ] && bailout "/etc/rsyncd.secrets not found!"
linbo_passwd=`grep ^linbo /etc/rsyncd.secrets | awk -F\: '{ print $2 }'`
if [ -z "$linbo_passwd" ]; then
 bailout "Cannot read linbo password from /etc/rsyncd.secrets!"
else
 sophomorix-passwd --user linbo --pass $linbo_passwd &> /dev/null ; RC=$?
 if [ $RC -ne 0 ]; then
  bailout "Failed to set linbo password!"
 fi
 # md5sum of linbo password goes into ramdisk
 linbo_md5passwd=`echo -n $linbo_passwd | md5sum | awk '{ print $1 }'`
fi

# begin to process linbofs.gz
echo "Processing LINBO groups:"

# create temp dir for linbofs content
mkdir -p $tmpdir
cd $tmpdir || bailout "Cannot change to $tmpdir!"
# unpack linbofs.gz to tmpdir
zcat $LINBODIR/linbofs.gz | cpio -i -d -H newc --no-absolute-filenames &> /dev/null ; RC=$?
[ $RC -ne 0 ] && bailout " Failed to unpack linbofs.gz!"

# store linbo md5 password
[ -n "$linbo_md5passwd" ] && echo -n "$linbo_md5passwd" > etc/linbo_passwd

# create ssmtp.conf
mkdir -p etc/ssmtp
echo "mailhub=$serverip:25" > etc/ssmtp/ssmtp.conf

# provide dropbear ssh host key
mkdir -p etc/dropbear
cp $SYSCONFDIR/linbo/dropbear_*_host_key etc/dropbear
mkdir -p etc/ssh
cp $SYSCONFDIR/linbo/ssh_host_[dr]sa_key* etc/ssh
mkdir -p .ssh
cp /root/.ssh/id_dsa.pub .ssh/authorized_keys
mkdir -p var/log
touch var/log/lastlog

if [ -z "$groups" ] || stringinstring default "$groups"; then
 # begin with default linbofs.gz
 echo -n " * default ... "

 # check and copy default start.conf
 set_serverip $LINBODIR/start.conf
 cp -f $LINBODIR/start.conf .

 # pack default linbofs.gz again
 find . | cpio --quiet -o -H newc | gzip -9c > $LINBODIR/linbofs.gz ; RC="$?"
 [ $RC -ne 0 ] && bailout "failed!"
 echo -e "[LINBOFS]\ntimestamp=`date +%Y\%m\%d\%H\%M`\nimagesize=`ls -l $LINBODIR/linbofs.gz | awk '{print $5}'`" > $LINBODIR/linbofs.gz.info
 echo "Ok!"
fi

# if no groups are given on cmdline then take all groups from workstations file
[ -z "$groups" ] && groups=`grep -v ^# $WIMPORTDATA | awk -F\; '{ print $3 " " $11 }' | grep -v -w 0 | awk '{ print $1 }' | sort -u`

# now process all groups found in $WIMPORTDATA
for i in $groups; do

 # skip group default
 [ "$group" = "default" ] && continue

 # do nothing if there is no start.conf for this group
 [ -e "$LINBODIR/start.conf.$i" ] || continue

 # print group name
 echo -n " * $i ... "

 # check and repair necessary conf files
 set_serverip $LINBODIR/start.conf.$i
 set_group $LINBODIR/start.conf.$i $i
 set_pxeconfig $i

 echo "Ok!"

done

# restart image services
for i in linbo-multicast linbo-bittorrent; do
 /etc/init.d/$i restart
done

# clean tmpdir
cd "$curdir"
rm -rf $tmpdir
rm -f $locker

