#
# Spec file for oss-linbo
# Copyright (c) 2016 Frank Schütte <fschuett@gymhim.de> Hildesheim, Germany.  All rights reserved.
#
# gcc 4.8 is needed, replace links gcc, g++, cpp
# don't clean build dir
Name:		oss-linbo
Summary:	OSS linux installation and boot environment
Version:	2.3.36
Release:	2
License:	GPLv3
Vendor:		openSUSE Linux
Packager:	fschuett@gymhim.de
Group:		Productivity/
Source:		%{name}-%{version}.tar.gz
Source121:	ipxe.efi
Source122:	ipxe.lkrn
# source archives, because build cannot download them created by list_sources.sh
Source1:        acl-2.2.52.src.tar.gz
Source2:        attr-2.4.47.src.tar.gz
Source3:        autoconf-2.69.tar.xz
Source4:        automake-1.15.1.tar.xz
Source5:        b43-fwcutter-015.tar.bz2
Source6:        bc-1.06.95.tar.bz2
Source7:        binutils-2.29.1.tar.xz
Source8:        bison-3.0.4.tar.xz
Source9:        broadcom-wl-5.100.138.tar.bz2
Source10:       busybox-1.27.2.tar.bz2
Source11:       bvi-1.4.0.src.tar.gz
Source12:       chntpw-source-140201.zip
Source13:       cloop_3.14.1.2.tar.xz
Source14:       ctorrent-dnh3.3.2.tar.gz
Source15:       dosfstools-4.1.tar.xz
Source16:       dropbear-2017.75.tar.bz2
Source17:       e2fsprogs-1.43.9.tar.xz
Source18:       efibootmgr-14.tar.gz
Source19:       efivar-30.tar.gz
Source20:       ethtool-4.13.tar.xz
Source21:       eudev-3.2.5.tar.gz
Source22:       expat-2.2.5.tar.bz2
Source23:       fakeroot_1.20.2.orig.tar.bz2
Source24:       flex-2.6.4.tar.gz
Source25:       freetype-2.8.1.tar.bz2
Source26:       fuse-2.9.7.tar.gz
Source27:       gawk-4.1.4.tar.xz
Source28:       gcc-6.4.0.tar.xz
Source29:       gettext-0.19.8.1.tar.xz
Source30:       glibc-glibc-2.26-146-gd300041c533a3d837c9f37a099bcc95466860e98.tar.gz
Source31:       gmp-6.1.2.tar.xz
Source32:       gperf-3.0.4.tar.gz
Source33:       gptfdisk-1.0.3.tar.gz
Source34:       grub2_2.02-2ubuntu8.debian.tar.xz
Source62:       grub2_2.02.orig.tar.xz
Source35:       inputproto-2.3.2.tar.bz2
Source36:       intltool-0.51.0.tar.gz
Source37:       kbproto-1.0.7.tar.bz2
Source38:       kmod-24.tar.xz
Source39:       libevdev-1.5.8.tar.xz
Source40:       libinput-1.8.2.tar.xz
Source41:       libpng-1.6.34.tar.xz
Source42:       libpthread-stubs-0.4.tar.bz2
Source43:       libtool-2.4.6.tar.xz
Source44:       libX11-1.6.5.tar.bz2
Source45:       libXau-1.0.8.tar.bz2
Source46:       libxcb-1.12.tar.bz2
Source47:       libXdmcp-1.1.2.tar.bz2
Source48:       libxkbcommon-0.7.1.tar.xz
Source49:       libxkbfile-1.0.9.tar.bz2
Source50:       libxml2-2.9.7.tar.gz
Source51:       libxslt-1.1.29.tar.gz
Source52:       linux-4.15.7.tar.xz
Source53:       linux-firmware-65b1c68c63f974d72610db38dfae49861117cae2.tar.gz
Source54:       lzip-1.19.tar.gz
Source55:       m4-1.4.18.tar.xz
Source56:       mpc-1.0.3.tar.gz
Source57:       mpfr-3.1.6.tar.xz
Source58:       ms-sys-2.4.1.tar.gz
Source59:       mtdev-1.1.4.tar.bz2
Source60:       ncurses-6.0.tar.gz
Source61:       ntfs-3g_ntfsprogs-2017.3.23.tgz
Source63:       parted-3.2.tar.xz
Source64:       patchelf-0.9.tar.bz2
Source65:       pcre2-10.30.tar.bz2
Source66:       pkgconf-0.9.12.tar.bz2
Source67:       popt-1.16.tar.gz
Source68:       Python-2.7.14.tar.xz
Source69:       qtbase-opensource-src-5.9.4.tar.xz
Source70:       reiserfsprogs-3.6.24.tar.xz
Source71:       rsync-3.1.3.tar.gz
Source72:       udpcast-20120424.tar.gz
Source73:       util-linux-2.31.1.tar.xz
Source74:       util-macros-1.19.1.tar.bz2
Source75:       ux500-firmware_1.1.3-6linaro1.tar.gz
Source76:       v14.1_Firmware.zip
Source77:       xcb-proto-1.12.tar.bz2
Source78:       xextproto-7.3.0.tar.bz2
Source79:       xf86bigfontproto-1.2.0.tar.bz2
Source80:       xkbcomp-1.4.0.tar.bz2
Source81:       xkeyboard-config-2.22.tar.bz2
Source82:       XML-Parser-2.44.tar.gz
Source83:       xproto-7.0.31.tar.bz2
Source84:       xtrans-1.3.5.tar.bz2
Source85:       xz-5.2.3.tar.bz2
Source86:       zd1211-firmware-1.4.tar.bz2
Source87:       zlib-1.2.11.tar.xz
Source88:       gdb-7.11.1.tar.xz
Source89:       sftpserver-0.2.2.tar.gz

BuildRequires:	unzip
BuildRequires:  glibc glibc-32bit glibc-devel glibc-devel-32bit
BuildRequires:	autoconf >= 2.69 automake >= 1.15 bc bison cpio
BuildRequires:	gcc gcc-32bit gcc-c++
BuildRequires:  oss-base
BuildRequires:	flex gettext git freetype2-devel libtool 
BuildRequires:	libopenssl-devel ncurses-devel python python-argparse rsync texinfo unzip wget efont-unicode
BuildRequires:  cmake quilt
BuildRequires:	make >= 4.0

BuildRoot:    %{_tmppath}/%{name}-root
Requires:	logrotate wakeonlan BitTorrent BitTorrent-curses syslinux6 xorriso >= 1.2.4
Requires(post):	%insserv_prereq %fillup_prereq dropbear pwgen

PreReq: %insserv_prereq openschool-base


%description
This package provides a boot environment based on linux installation and boot environment (linbo) for cloning clients.

Authors:
--------
        see readme

%prep
%setup -D

%build

OPATH=$PATH
export PATH=%{_builddir}:${OPATH%:.}
export BR2_DL_DIR=%{_sourcedir}
make -f rpm/Makefile build

export PATH=$OPATH

%install
# install main conf
mkdir -p %{buildroot}/etc/linbo
cat >%{buildroot}/etc/linbo/linbo.conf <<EOF
# /etc/linbo/linbo.conf
# main conf file
FLAVOUR=oss
ENVDEFAULTS=/usr/share/linbo/dist.conf
SYSLINUXSRC="/usr/share/syslinux"
ISOLINUXSRC="\$SYSLINUXSRC"

EOF

# install files and directories
mkdir -p %{buildroot}/etc/linbo
install etc/ssh_config %{buildroot}/etc/linbo/ssh_config
install etc/start.conf.default %{buildroot}/etc/linbo/start.conf.default.in
mkdir -p %{buildroot}/srv/tftp
for d in boot examples icons linuxmuster-win; do
  mkdir -p %{buildroot}/srv/tftp/${d}
  cp -r linbo/${d}/* %{buildroot}/srv/tftp/${d}/
done
pushd %{buildroot}/srv/tftp/boot/grub/
ln -sf ../../icons/linbo_wallpaper_1024x768.png linbo_wallpaper.png
popd
install linbofs/etc/linbo-version %{buildroot}/srv/tftp
mkdir -p %{buildroot}/srv/tftp/boot/grub
install %{S:121} %{buildroot}/srv/tftp/boot/grub/
install %{S:122} %{buildroot}/srv/tftp/boot/grub/
cp -r build/build-x86_64/boot/grub/* %{buildroot}/srv/tftp/boot/grub/
mkdir -p %{buildroot}/usr/share/linbo
cp -r share/* %{buildroot}/usr/share/linbo/
find %{buildroot}/usr/share/linbo -name '*.lmn?' -exec rm -f {} \;
find %{buildroot}/usr/share/linbo -name 'lmn[67]*' -exec rm -f {} \;
for f in `find %{buildroot}/usr/share/linbo -name '*.oss'`; do
  nf=${f%.oss}
  mv $f $nf
done
install rpm/dist.conf %{buildroot}/usr/share/linbo/dist.conf
mkdir -p %{buildroot}/var/cache/linbo
mkdir -p %{buildroot}/var/adm/fillup-templates
install rpm/sysconfig.linbo-multicast %{buildroot}/var/adm/fillup-templates/sysconfig.linbo-multicast
install rpm/sysconfig.linbo-bittorrent %{buildroot}/var/adm/fillup-templates/sysconfig.linbo-bittorrent
install rpm/sysconfig.linbofs %{buildroot}/var/adm/fillup-templates/sysconfig.linbofs
mkdir -p %{buildroot}/etc/init.d
mkdir -p %{buildroot}/usr/sbin
install rpm/linbo-bittorrent.init %{buildroot}/etc/init.d/linbo-bittorrent
ln -sf ../../etc/init.d/linbo-bittorrent %{buildroot}/usr/sbin/rclinbo-bittorrent
install rpm/linbo-multicast.init %{buildroot}/etc/init.d/linbo-multicast
ln -sf ../../etc/init.d/linbo-multicast %{buildroot}/usr/sbin/rclinbo-multicast
install share/templates/grub.cfg.pxe %{buildroot}/srv/tftp/boot/grub/grub.cfg
install build/build-i386/images/bzImage %{buildroot}/srv/tftp/linbo
install build/build-i386/images/bzImage.md5 %{buildroot}/srv/tftp/linbo.md5
install build/build-i386/images/rootfs.cpio.lz %{buildroot}/srv/tftp/linbofs.lz
install build/build-i386/images/rootfs.cpio.lz.md5 %{buildroot}/srv/tftp/linbofs.lz.md5
install build/build-x86_64/images/bzImage %{buildroot}/srv/tftp/linbo64
install build/build-x86_64/images/bzImage.md5 %{buildroot}/srv/tftp/linbo64.md5
install build/build-x86_64/images/rootfs.cpio.lz %{buildroot}/srv/tftp/linbofs64.lz
install build/build-x86_64/images/rootfs.cpio.lz.md5 %{buildroot}/srv/tftp/linbofs64.lz.md5
mkdir -p %{buildroot}/usr/bin
install build/build-x86_64/host/bin/grub-mkimage %{buildroot}/usr/bin/linbo-grub-mkimage
install build/build-x86_64/host/bin/grub-mkstandalone %{buildroot}/usr/bin/linbo-grub-mkstandalone
pushd %{buildroot}/usr/share/linbo
ln -sf ../../bin/linbo-grub-mkimage grub-mkimage
ln -sf ../../bin/linbo-grub-mkstandalone grub-mkstandalone
popd
mkdir -p %{buildroot}/var/log/linbo
pushd %{buildroot}/srv/tftp/
ln -sf ../../var/log/linbo log
popd
mkdir -p %{buildroot}/usr/sbin
pushd %{buildroot}/usr/sbin/
ln -sf ../share/linbo/linbo-ssh.sh linbo-ssh
ln -sf ../share/linbo/linbo-scp.sh linbo-scp
ln -sf ../share/linbo/linbo-remote.sh linbo-remote
ln -sf ../share/linbo/update-linbofs.sh update-linbofs
popd
mkdir -p %{buildroot}/usr/share/doc/packages/oss-linbo
pushd %{buildroot}/usr/share/doc/packages/oss-linbo/
ln -sf ../../../../../srv/tftp/examples examples
popd
mkdir -p %{buildroot}/etc/logrotate.d
install rpm/logrotate %{buildroot}/etc/logrotate.d/linbo
mkdir -p %{buildroot}/srv/tftp/{linbocmd,torrentadds,winact,tmp,backup}
mkdir -p %{buildroot}/srv/tftp/boot/grub/{spool,hostcfg}
# rsyncd conf
install share/templates/rsyncd.conf %{buildroot}/etc/rsyncd.conf.in
install share/templates/rsyncd.secrets.oss %{buildroot}/etc/rsyncd.secrets.in
# bittorrent
install rpm/bittorrent.init %{buildroot}/etc/init.d/bittorrent
ln -sf ../../etc/init.d/bittorrent %{buildroot}/usr/sbin/rcbittorrent
mkdir -p %{buildroot}/var/adm/fillup-templates
install rpm/sysconfig.bittorrent %{buildroot}/var/adm/fillup-templates/sysconfig.bittorrent
mkdir -p %{buildroot}/var/lib/bittorrent
mkdir -p %{buildroot}/var/log/bittorrent

mkdir -p %{buildroot}/etc/linbo/import-workstations.d
mkdir -p %{buildroot}/usr/sbin
install rpm/import_workstations %{buildroot}/usr/sbin/import_workstations
mkdir -p %{buildroot}/usr/share/linbo
install rpm/linbo_sync_hosts.pl %{buildroot}/usr/share/linbo/linbo_sync_hosts.pl
install rpm/linbo_update_workstations.pl %{buildroot}/usr/share/linbo/linbo_update_workstations.pl
install rpm/linbo_write_dhcpd.pl %{buildroot}/usr/share/linbo/linbo_write_dhcpd.pl
install rpm/wimport.sh %{buildroot}/usr/share/linbo/wimport.sh

export NO_BRP_CHECK_RPATH=true

%pre
if ! grep -qw ^bittorrent /etc/passwd; then
    useradd -r -g nogroup -c "BitTorrent User" -d /var/lib/bittorrent -s /bin/false bittorrent
fi

%post
# setup rights
if [ -e "/etc/sysconfig/schoolserver" ]
then
   DATE=`date +%Y-%m-%d:%H-%M`
   SCHOOL_SERVER=10.0.0.2
   . /etc/sysconfig/schoolserver
   LINBODIR=/srv/tftp
   LINBOSHAREDIR=/usr/share/linbo
   [ -e /etc/linbo/linbo.conf ] && . /etc/linbo/linbo.conf
   [ -e $ENVDEFAULTS ] && . $ENVDEFAULTS
   FILE=/etc/rsyncd.conf
   if [ -e $FILE ]
   then
     cp $FILE $FILE.$DATE
   fi
   cp $FILE.in $FILE
   sed -i -e "s|@@linbodir@@|$LINBODIR|g" -e "s|@@linbosharedir@@|$LINBOSHAREDIR|g" $FILE
   FILE=/etc/rsyncd.secrets
   LINBOPW="$(pwgen -1)"
   if [ ! -e $FILE ]
   then
     cp $FILE.in $FILE
     sed "s/^linbo:.*/linbo:$LINBOPW/" -i $FILE
   elif ! grep -q ^linbo: $FILE; then
     echo "linbo:$LINBOPW" >>$FILE
   fi
   FILE=/etc/linbo/start.conf.default
   if [ -e $FILE ]; then
     cp $FILE $FILE.$DATE
   fi
   cp $FILE.in $FILE
   sed -i "s@Server = .*@Server = $SCHOOL_SERVER@g" $FILE
   [ -e /srv/tftp/start.conf ] || ln -sf $FILE /srv/tftp/start.conf
   
   # create dropbear ssh keys
   if [ ! -s "/etc/linbo/ssh_host_rsa_key" ]; then
     ssh-keygen -t rsa -N "" -f /etc/linbo/ssh_host_rsa_key
     dropbearconvert openssh dropbear /etc/linbo/ssh_host_rsa_key /etc/linbo/dropbear_rsa_host_key
   fi
   if [ ! -s "/etc/linbo/ssh_host_dsa_key" ]; then
     ssh-keygen -t dsa -N "" -f /etc/linbo/ssh_host_dsa_key
     dropbearconvert openssh dropbear /etc/linbo/ssh_host_dsa_key /etc/linbo/dropbear_dsa_host_key
   fi
   if [ ! -s "/etc/linbo/ssh_host_ecdsa_key" ]; then
     ssh-keygen -t ecdsa -N "" -f /etc/linbo/ssh_host_ecdsa_key
     dropbearconvert openssh dropbear /etc/linbo/ssh_host_ecdsa_key /etc/linbo/dropbear_ecdsa_host_key
   fi
   # create missing ecdsa ssh key
   rootkey="/root/.ssh/id_ecdsa"
   if [ ! -e "$rootkey" ]; then
     echo -n "Creating ssh key $rootkey ... "
     ssh-keygen -N "" -q -t ecdsa -f "$rootkey"
     echo "Done!"
   fi
   update-linbofs
fi
%fillup_only
%{fillup_only -n linbofs}
%{fillup_and_insserv -yn bittorrent bittorrent}
%{fillup_and_insserv -yn linbo-bittorrent linbo-bittorrent}
%{fillup_and_insserv -f -y linbo-multicast}
systemctl enable rsyncd
systemctl start rsyncd

%postun
%restart_on_update bittorrent linbo-bittorrent linbo-multicast rsyncd
%insserv_cleanup

%files
%defattr(-,root,root)
%dir /etc/linbo
%dir /etc/linbo/import-workstations.d
%config /etc/linbo/linbo.conf
%attr(644,root,root) %config /etc/linbo/ssh_config
%attr(644,root,root) %config /etc/linbo/start.conf.default.in
%config /etc/logrotate.d/linbo
%attr(-,nobody,root) %dir /var/log/linbo
%dir /var/cache/linbo
%dir /srv/tftp
/srv/tftp/log
%dir /srv/tftp/linbocmd
%dir /srv/tftp/torrentadds
%dir /srv/tftp/winact
%dir /srv/tftp/boot
%dir /srv/tftp/boot/grub
%dir /srv/tftp/boot/grub/spool
%dir /srv/tftp/boot/grub/hostcfg
%dir /srv/tftp/tmp
%dir /srv/tftp/backup
%attr(0755,bittorrent,root) /var/lib/bittorrent
%attr(0755,bittorrent,root) /var/log/bittorrent
/etc/init.d/bittorrent
/usr/sbin/rcbittorrent
%attr(0644,root,root) /var/adm/fillup-templates/sysconfig.bittorrent
%attr(0644,root,root) /var/adm/fillup-templates/sysconfig.linbo-bittorrent
%attr(0644,root,root) /var/adm/fillup-templates/sysconfig.linbo-multicast
%attr(0644,root,root) /var/adm/fillup-templates/sysconfig.linbofs
/etc/init.d/linbo-bittorrent
/usr/sbin/rclinbo-bittorrent
/etc/init.d/linbo-multicast
/usr/sbin/rclinbo-multicast
%attr(0640,root,root) /etc/rsyncd.conf.in
%attr(0600,root,root) /etc/rsyncd.secrets.in
/srv/tftp/boot/grub/ipxe.lkrn
/srv/tftp/boot/grub/ipxe.efi
/srv/tftp/boot/grub/grub.cfg
/srv/tftp/boot/grub/locale
/srv/tftp/boot/grub/i386-pc
/srv/tftp/boot/grub/i386-efi
/srv/tftp/boot/grub/x86_64-efi
/srv/tftp/boot/grub/fonts
/srv/tftp/boot/grub/linbo_wallpaper.png
/srv/tftp/boot/grub/themes
/srv/tftp/icons
/srv/tftp/linbo
%attr(0644,root,root) /srv/tftp/linbo.md5
/srv/tftp/linbofs.lz
/srv/tftp/linbofs.lz.md5
/srv/tftp/linbo64
%attr(0644,root,root) /srv/tftp/linbo64.md5
/srv/tftp/linbofs64.lz
/srv/tftp/linbofs64.lz.md5
/srv/tftp/examples
/srv/tftp/linuxmuster-win
/srv/tftp/linbo-version
/usr/share/linbo
/usr/share/doc/packages/oss-linbo
%defattr(0755,root,root)
/usr/sbin/import_workstations
/usr/sbin/linbo-ssh
/usr/sbin/linbo-scp
/usr/sbin/linbo-remote
/usr/sbin/update-linbofs
/usr/bin/linbo-grub-mkimage
/usr/bin/linbo-grub-mkstandalone

%changelog
