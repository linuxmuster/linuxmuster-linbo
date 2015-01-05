#!/bin/bash
#
# creating/updating linbofs.lz with linbo password and ssh keys
# has to be invoked during linuxmuster-setup,  package upgrade or
# linbo password change in /etc/rsyncd.secrets.
# 
# thomas@linuxmuster.net
# GPL V3
# 05.02.2014
#

# read linuxmuster environment
. /usr/share/linuxmuster/config/dist.conf || exit 1
. $HELPERFUNCTIONS || exit 1

if [ ! -e "$INSTALLED" ]; then
 echo "linuxmuster.net is not configured! Aborting!"
 exit 1
fi

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

# check for default linbofs.lz
[ ! -s "$LINBODIR/linbofs.lz" ] && bailout "Error: $LINBODIR/linbofs.lz not found!"

# grep linbo rsync password to sync it with linbo account
[ ! -s /etc/rsyncd.secrets ] && bailout "/etc/rsyncd.secrets not found!"
linbo_passwd="$(grep ^linbo /etc/rsyncd.secrets | awk -F\: '{ print $2 }')"
if [ -z "$linbo_passwd" ]; then
 bailout "Cannot read linbo password from /etc/rsyncd.secrets!"
else
 sophomorix-passwd --user linbo --pass "$linbo_passwd" &> /dev/null ; RC="$?"
 [ "$RC" != "0" ] && echo "WARNING: Sophomorix failed to set linbo password! Expect problems with the user db!"
 # md5sum of linbo password goes into ramdisk
 linbo_md5passwd=`echo -n $linbo_passwd | md5sum | awk '{ print $1 }'`
fi

# begin to process linbofs.lz
echo "Processing linbofs update ..."

# create temp dir for linbofs content
mkdir -p $tmpdir
cd $tmpdir || bailout "Cannot change to $tmpdir!"
# unpack linbofs.lz to tmpdir
xzcat $LINBODIR/linbofs.lz | cpio -i -d -H newc --no-absolute-filenames &> /dev/null ; RC=$?
[ $RC -ne 0 ] && bailout " Failed to unpack linbofs.lz!"

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

# copy default start.conf
cp -f $LINBODIR/start.conf .

# pack default linbofs.lz again
find . | cpio --quiet -o -H newc | lzma -zcv > $LINBODIR/linbofs.lz ; RC="$?"
[ $RC -ne 0 ] && bailout "failed!"
# deprecated
#echo -e "[LINBOFS]\ntimestamp=`date +%Y\%m\%d\%H\%M`\nimagesize=`ls -l $LINBODIR/linbofs.lz | awk '{print $5}'`" > $LINBODIR/linbofs.lz.info
echo "Ok!"

# clean tmpdir
cd "$curdir"
rm -rf $tmpdir
rm -f $locker

