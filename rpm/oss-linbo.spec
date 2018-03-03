#
# Spec file for oss-linbo
# Copyright (c) 2016 Frank Schütte <fschuett@gymhim.de> Hildesheim, Germany.  All rights reserved.
#
# gcc 4.8 is needed, replace links gcc, g++, cpp
# don't clean build dir
Name:		oss-linbo
Summary:	OSS linux installation and boot environment
Version:	2.3.35
Release:	0
License:	GPLv3
Vendor:		openSUSE Linux
Distribution:	SLE11
Packager:	fschuett@gymhim.de
Group:		Productivity/
Source:		%{name}-%{version}.tar.gz
Source121:	ipxe.efi
Source122:	ipxe.lkrn
# source archives, because build cannot download them created by list_sources.sh
Source1:        acl-2.2.52.src.tar.gz
Source2:        attr-2.4.47.src.tar.gz
Source3:        autoconf-2.69.tar.xz
Source4:        automake-1.15.tar.xz
Source5:        bc-1.06.95.tar.bz2
Source6:        binutils-2.28.1.tar.xz
Source7:        bison-3.0.4.tar.xz
Source8:        busybox-1.27.1.tar.bz2
Source9:        bvi-1.4.0.src.tar.gz
Source10:       chntpw-source-140201.zip
Source11:       cloop_3.14.1.2.tar.xz
Source12:       ctorrent-dnh3.3.2.tar.gz
Source13:       dosfstools-4.1.tar.xz
Source14:       dropbear-2017.75.tar.bz2
Source15:       e2fsprogs-1.43.4.tar.xz
Source16:       efibootmgr-14.tar.gz
Source17:       efivar-30.tar.gz
Source18:       ethtool-4.10.tar.xz
Source19:       eudev-3.2.2.tar.gz
Source20:       expat-2.2.2.tar.bz2
Source21:       fakeroot_1.20.2.orig.tar.bz2
Source22:       flex-2.6.4.tar.gz
Source23:       freetype-2.8.tar.bz2
Source24:       fuse-2.9.7.tar.gz
Source25:       gawk-4.1.4.tar.xz
Source26:       gcc-6.4.0.tar.xz
Source27:       gettext-0.19.8.1.tar.xz
Source28:       glibc-2.25.tar.xz
Source29:       gmp-6.1.2.tar.xz
Source30:       gperf-3.0.4.tar.gz
Source31:       gptfdisk-1.0.1.tar.gz
Source32:       grub-2.02.tar.gz
Source33:       inputproto-2.3.2.tar.bz2
Source34:       intltool-0.51.0.tar.gz
Source35:       kbproto-1.0.7.tar.bz2
Source36:       kmod-24.tar.xz
Source37:       libevdev-1.5.7.tar.xz
Source38:       libinput-1.7.2.tar.xz
Source39:       libpng-1.6.31.tar.xz
Source40:       libpthread-stubs-0.4.tar.bz2
Source41:       libtool-2.4.6.tar.xz
Source42:       libX11-1.6.5.tar.bz2
Source43:       libXau-1.0.8.tar.bz2
Source44:       libxcb-1.12.tar.bz2
Source45:       libXdmcp-1.1.2.tar.bz2
Source46:       libxkbcommon-0.7.1.tar.xz
Source47:       libxkbfile-1.0.9.tar.bz2
Source48:       libxml2-2.9.4.tar.gz
Source49:       libxslt-1.1.29.tar.gz
Source50:       linux-4.12.10.tar.xz
Source51:       lzip-1.18.tar.gz
Source52:       m4-1.4.18.tar.xz
Source53:       mpc-1.0.3.tar.gz
Source54:       mpfr-3.1.5.tar.xz
Source55:       ms-sys-2.4.1.tar.gz
Source56:       mtdev-1.1.4.tar.bz2
Source57:       ncurses-6.0.tar.gz
Source58:       ntfs-3g_ntfsprogs-2017.3.23.tgz
Source59:       oss-linbo-2.3.29.tar.gz
Source60:       parted-3.2.tar.xz
Source61:       patchelf-0.9.tar.bz2
Source62:       pcre2-10.23.tar.bz2
Source63:       pkgconf-0.9.12.tar.bz2
Source64:       popt-1.16.tar.gz
Source65:       Python-2.7.13.tar.xz
Source66:       qtbase-opensource-src-5.9.1.tar.xz
Source67:       reiserfsprogs-3.6.24.tar.xz
Source68:       rsync-3.1.2.tar.gz
Source69:       udpcast-20120424.tar.gz
Source70:       util-linux-2.30.1.tar.xz
Source71:       util-macros-1.19.1.tar.bz2
Source72:       xcb-proto-1.12.tar.bz2
Source73:       xextproto-7.3.0.tar.bz2
Source74:       xf86bigfontproto-1.2.0.tar.bz2
Source75:       xkbcomp-1.4.0.tar.bz2
Source76:       xkeyboard-config-2.21.tar.bz2
Source77:       XML-Parser-2.44.tar.gz
Source78:       xproto-7.0.31.tar.bz2
Source79:       xtrans-1.3.5.tar.bz2
Source80:       xz-5.2.3.tar.bz2
Source81:       zlib-1.2.11.tar.xz
Source82:       linux-firmware-a3a26af24e29c818ef9b5661856018e21a5c49fb.tar.gz

BuildRequires:	unzip openschool-base
BuildRequires:	gcc48 gcc48-32bit gcc48-c++ glibc glibc-32bit glibc-devel glibc-devel-32bit
BuildRequires:	autoconf >= 2.69 automake >= 1.15 bc bison cpio
%if 0%{?sles_version} == 11
BuildRequires:  openssl-certs
%endif
BuildRequires:	flex gettext git freetype2-devel libtool 
BuildRequires:	ncurses-devel python rsync texinfo unzip wget efont-unicode
BuildRequires:  cmake

BuildRoot:    %{_tmppath}/%{name}-root
Requires:	logrotate wakeonlan BitTorrent BitTorrent-curses syslinux6 xorriso
Requires(post):	%insserv_prereq %fillup_prereq dropbear pwgen

PreReq: %insserv_prereq openschool-base


%description
This package provides a boot environment based on linux installation and boot environment (linbo) for cloning clients.

Authors:
--------
        see readme

%prep
%setup -D
ln -sf /usr/bin/gcc-4.8 %{_builddir}/gcc
ln -sf /usr/bin/gcc-ar-4.8 %{_builddir}/gcc-ar
ln -sf /usr/bin/gcc-nm-4.8 %{_builddir}/gcc-nm
ln -sf /usr/bin/gcc-ranlib-4.8 %{_builddir}/gcc-ranlib
ln -sf /usr/bin/gcc-4.8 %{_builddir}/cc
ln -sf /usr/bin/g++-4.8 %{_builddir}/g++
ln -sf /usr/bin/cpp-4.8 %{_builddir}/cpp
ln -sf /usr/bin/gcov-4.8 %{_builddir}/gcov

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
cp -r build/boot/grub/* %{buildroot}/srv/tftp/boot/grub/
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
mkdir -p %{buildroot}/srv/tftp/boot/grub/fonts
install buildroot-external/board/rootfs_overlay/usr/share/grub/unicode.pf2 %{buildroot}/srv/tftp/boot/grub/fonts
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
mkdir -p %{buildroot}/usr/share/oss/tools
install rpm/import_workstations %{buildroot}/usr/share/oss/tools/import_workstations
mkdir -p %{buildroot}/usr/sbin
install rpm/oss_modify_dhcpStatements.pl %{buildroot}/usr/sbin/oss_modify_dhcpStatements.pl
install rpm/oss_workstations_sync_hosts.pl %{buildroot}/usr/sbin/oss_workstations_sync_hosts.pl

mkdir -p %{buildroot}/usr/share/linbo
install rpm/wimport.sh %{buildroot}/usr/share/linbo/wimport.sh

mkdir -p %{buildroot}/usr/share/oss/plugins/add_user
install rpm/add_linbopxe.pl %{buildroot}/usr/share/oss/plugins/add_user/add_linbopxe.pl

%pre
if ! grep -qw ^bittorrent /etc/passwd; then
    useradd -r -g nogroup -c "BitTorrent User" -d /var/lib/bittorrent -s /bin/false bittorrent
fi

%post
# setup rights
if [ -d /home/sysadmins/admin ]
then
   DATE=`date +%Y-%m-%d:%H-%M`
   SCHOOL_SERVER=10.0.0.2
   [ -e /etc/sysconfig/schoolserver ] && . /etc/sysconfig/schoolserver
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
   if [ ! -e $FILE ]
   then
     cp $FILE.in $FILE
     LINBOPW="$(pwgen -1)"
     sed "s/^linbo:.*/linbo:$LINBOPW/" -i $FILE
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
   # force recreate tools index on next access
   rm -f /usr/share/oss/tools/scripts_list.xml
   update-linbofs
fi
%fillup_only
%{fillup_only -n linbofs}
%{fillup_and_insserv -yn bittorrent bittorrent}
%{fillup_and_insserv -yn linbo-bittorrent linbo-bittorrent}
%{fillup_and_insserv -f -y linbo-multicast}
%{fillup_and_insserv -f -Y rsyncd}

%postun
%restart_on_update bittorrent linbo-bittorrent linbo-multicast rsyncd
%insserv_cleanup
# force recreate tools index on next access
rm -f /usr/share/oss/tools/scripts_list.xml

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
%dir /srv/tftp/log
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
%dir /usr/share/oss
%dir /usr/share/oss/plugins
%dir /usr/share/oss/plugins/add_user
%dir /usr/share/oss/tools
%defattr(0755,root,root)
/usr/share/oss/plugins/add_user/add_linbopxe.pl
/usr/share/oss/tools/import_workstations
/usr/sbin/linbo-ssh
/usr/sbin/linbo-scp
/usr/sbin/linbo-remote
/usr/sbin/update-linbofs
/usr/sbin/oss_modify_dhcpStatements.pl
/usr/sbin/oss_workstations_sync_hosts.pl

%changelog
