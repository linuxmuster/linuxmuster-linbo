#!/bin/bash
#
# creating/updating linbofs.lz with linbo password and ssh keys
# has to be invoked during linuxmuster-setup,  package upgrade or
# linbo password change in /etc/rsyncd.secrets.
#
# thomas@linuxmuster.net
# GPL V3
# 20170130
#

# read linuxmuster environment
source /etc/linbo/linbo.conf || exit 1
source $ENVDEFAULTS || exit 1
source $HELPERFUNCTIONS || exit 1
[ -n "$LINBOCACHEDIR" ] || LINBOCACHEDIR="/var/cache/linuxmuster-linbo"

if [ "$FLAVOUR" != "oss" ]; then
  if [ ! -e "$SETUPINI" -a ! -e "$INSTALL" ]; then
    echo "linuxmuster.net is not configured! Aborting!"
    [ "$FLAVOUR" = "lmn6" ] && exit 1
    exit 0
  fi
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
chmod 400 "$locker"
curdir=`pwd`

# clean tmpdir and exit with error
bailout() {
 echo "$1"
 cd "$curdir"
 [ -n "$locker" -a -e "$locker" ] && rm -f "$locker"
 exit 1
}

if [ "$FLAVOUR" = "lmn6" ]; then
  # this script makes only sense if imaging=linbo
  [ "$imaging" != "linbo" ] && bailout "Imaging system is $imaging and not linbo!"
fi

update_linbofs() {
 local suffix=$1
 local linbofscachedir="$LINBOCACHEDIR/linbofs$suffix"
 local linbofs="$LINBODIR/linbofs${suffix}.lz"
 if [ "$FLAVOUR" = "oss" ]; then
   linbofs="$LINBOSHAREDIR/initrd/linbofs${suffix}.lz"
 fi
 local linbofs_md5="$linbofs".md5
 rm -f "$linbofs_md5"
 rm -rf "$linbofscachedir"
 mkdir -p "$linbofscachedir"

 # check for default linbofs${suffix}.lz
 [ ! -s "$linbofs" ] && bailout "Error: $linbofs not found!"

 # begin to process linbofs${suffix}.lz
 echo "Processing linbofs${suffix} update ..."

 # unpack linbofs.lz to cache dir
 cd "$linbofscachedir" || bailout "Cannot change to $linbofscachedir!"
 xzcat "$linbofs" | cpio -i -d -H newc --no-absolute-filenames &> /dev/null ; RC=$?
 [ $RC -ne 0 ] && bailout " Failed to unpack $(basename "$linbofs")!"

 # store linbo md5 password
 echo -n "$linbo_md5passwd" > etc/linbo_passwd

 # provide dropbear ssh host key
 mkdir -p etc/dropbear
 mkdir -p etc/ssh
 if [ "$FLAVOUR" = "oss" ]; then
   cp "$SYSCONFDIR/sysconfig/linbofs" etc/linbofs.conf
 elif [ -e "$SYSCONFDIR/linbo/linbofs.conf" ]; then
   cp "$SYSCONFDIR/linbo/linbofs.conf" etc
 fi
 if [ "$FLAVOUR" = "lmn7" ]; then
   cp $SYSDIR/linbo/dropbear_*_host_key etc/dropbear
   cp $SYSDIR/linbo/ssh_host_*_key* etc/ssh
 else
   cp $SYSCONFDIR/linbo/dropbear_*_host_key etc/dropbear
   cp $SYSCONFDIR/linbo/ssh_host_*_key* etc/ssh
 fi
 if [ "$FLAVOUR" = "oss" ]; then
   ROOTSSH="root/.ssh"
 else
   ROOTSSH=".ssh"
 fi
 mkdir -p $ROOTSSH
 cat /root/.ssh/id_{ec,}dsa.pub > $ROOTSSH/authorized_keys
 mkdir -p var/log
 touch var/log/lastlog

 # copy default start.conf
 cp -f $LINBODIR/start.conf .

 if [ "$FLAVOUR" = "oss" ]; then
   linbofs="$LINBODIR/linbofs${suffix}.lz"
 fi
 # pack default linbofs${suffix}.lz again
 find . | cpio --quiet -o -H newc | lzma -zcv > "$linbofs" ; RC="$?"
 [ $RC -ne 0 ] && bailout "failed!"
 # create md5sum file
 md5sum "$linbofs"  | awk '{ print $1 }' > "$linbofs_md5"

 cd "$curdir"

 echo "Ok!"

}

# create download links for linbo kernel and initrd so it can be downloaded per http
create_www_links(){
 [ -d /var/www ] || return
 for i in linbo linbo-np linbo64 linbofs.lz linbofs-np.lz linbofs64.lz linbo.iso; do
  ln -sf "$LINBODIR/$i" /var/www/
 done
}

# grep linbo rsync password to sync it with linbo account
[ ! -s /etc/rsyncd.secrets ] && bailout "/etc/rsyncd.secrets not found!"
linbo_passwd="$(grep ^linbo /etc/rsyncd.secrets | awk -F\: '{ print $2 }')"
if [ -z "$linbo_passwd" ]; then
  bailout "Cannot read linbo password from /etc/rsyncd.secrets!"
elif [ "$FLAVOUR" = "lmn6" ]; then
  sophomorix-passwd --user linbo --pass "$linbo_passwd" &> /dev/null ; RC="$?"
  if [ "$RC" = "0" ]; then
    echo "Successfully set linbo password."
  else
    echo "WARNING: Sophomorix failed to set linbo password! Probably postgres or slapd services do not run!"
  fi
fi

# md5sum of linbo password goes into ramdisk
linbo_md5passwd=`echo -n $linbo_passwd | md5sum | awk '{ print $1 }'`

# process linbofs updates
update_linbofs
[ "$FLAVOUR" != "oss" ] && update_linbofs -np
update_linbofs 64

# create iso files
"$LINBOSHAREDIR"/make-linbo-iso.sh

# obsolete
[ "$FLAVOUR" = "lmn6" ] && create_www_links

rm -f "$locker"
