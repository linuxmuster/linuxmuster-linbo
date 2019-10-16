#
# Spec file for oss-linbo
# Copyright (c) 2016 Frank Schütte <fschuett@gymhim.de> Hildesheim, Germany.  All rights reserved.
#
# don't clean build dir
Name:		oss-linbo
Summary:	OSS linux installation and boot environment
Version:	2.3.44
Release:	3
License:	GPLv3
Vendor:		openSUSE Linux
Packager:	fschuett@gymhim.de
Group:		Productivity/
Source:		%{name}-%{version}.tar.gz
Source121:	ipxe.efi
Source122:	ipxe.lkrn
# source archives, because build cannot download them created by list_sources.sh
Source1:        acl-2.2.53.tar.gz
Source2:        attr-2.4.48.tar.gz
Source3:        autoconf-2.69.tar.xz
Source4:        automake-1.15.1.tar.xz
Source5:        b43-fwcutter-015.tar.bz2
Source6:        bc-1.06.95.tar.bz2
Source7:        binutils-2.31.1.tar.xz
Source8:        bison-3.0.4.tar.xz
Source9:        broadcom-wl-5.100.138.tar.bz2
Source10:       busybox-1.30.1.tar.bz2
Source11:       bvi-1.4.0.src.tar.gz
Source12:       chntpw-source-140201.zip
Source13:       Cloop-5.1.zip
Source14:       ctorrent-dnh3.3.2.tar.gz
Source15:       dosfstools-4.1.tar.xz
Source16:       dropbear-2019.78.tar.bz2
Source17:       e2fsprogs-1.44.5.tar.xz
Source18:       efibootmgr-15.tar.gz
Source19:       efivar-35.tar.gz
Source20:       ethtool-4.19.tar.xz
Source21:       eudev-3.2.7.tar.gz
Source22:       expat-2.2.7.tar.bz2
Source23:       fakeroot_1.20.2.orig.tar.bz2
Source24:       flex-2.6.4.tar.gz
Source25:       freetype-2.9.1.tar.bz2
Source26:       fuse-2.9.9.tar.gz
Source27:       gawk-4.2.1.tar.xz
Source28:       gcc-7.4.0.tar.xz
Source29:       gettext-0.19.8.1.tar.xz
Source30:       gettext-tiny-c6dcdcdef801127549d3906d153c061880d25a73.tar.gz
Source31:       glibc-2.29-11-ge28ad442e73b00ae2047d89c8cc7f9b2a0de5436.tar.gz
Source32:       gmp-6.1.2.tar.xz
Source33:       gperf-3.0.4.tar.gz
Source34:       gptfdisk-1.0.3.tar.gz
Source35:       grub2_2.02-2ubuntu8.debian.tar.xz
Source36:       grub2_2.02.orig.tar.xz
Source37:       intltool-0.51.0.tar.gz
Source38:       kmod-25.tar.xz
Source39:       libevdev-1.6.0.tar.xz
Source40:       libffi-v3.3-rc0.tar.gz
Source41:       libinput-1.13.2.tar.xz
Source42:       libpng-1.6.37.tar.xz
Source43:       libpthread-stubs-0.4.tar.bz2
Source44:       libtool-2.4.6.tar.xz
Source45:       libX11-1.6.7.tar.bz2
Source46:       libXau-1.0.9.tar.bz2
Source47:       libxcb-1.13.tar.bz2
Source48:       libXdmcp-1.1.3.tar.bz2
Source49:       libxkbcommon-0.8.3.tar.xz
Source50:       libxkbfile-1.1.0.tar.bz2
Source51:       libxml2-2.9.9.tar.gz
Source52:       libxslt-1.1.32.tar.gz
Source53:       linux-5.1.16.tar.xz
Source54:       linux-firmware-1baa34868b2c0a004dc595b20678145e3fff83e7.tar.gz
Source55:       m4-1.4.18.tar.xz
Source56:       meson-0.50.1.tar.gz
Source57:       mpc-1.1.0.tar.gz
Source58:       mpfr-4.0.2.tar.xz
Source59:       ms-sys-2.4.1.tar.gz
Source60:       mtdev-1.1.4.tar.bz2
Source61:       ncurses-6.1.tar.gz
Source62:       ninja-v1.9.0.tar.gz
Source63:       ntfs-3g_ntfsprogs-2017.3.23.tgz
Source64:       parted-3.2.tar.xz
Source65:       patchelf-0.9.tar.bz2
Source66:       pcre2-10.32.tar.bz2
Source67:       pkgconf-1.6.1.tar.xz
Source68:       popt-1.16.tar.gz
Source69:       Python-2.7.16.tar.xz
Source70:       Python-3.7.3.tar.xz
Source71:       qtbase-everywhere-src-5.12.2.tar.xz
Source72:       reiserfsprogs-3.6.27.tar.xz
Source73:       rsync-3.1.3.tar.gz
Source74:       setuptools-41.0.1.zip
Source75:       udpcast-20120424.tar.gz
Source76:       util-linux-2.33.tar.xz
Source77:       util-macros-1.19.2.tar.bz2
Source78:       ux500-firmware_1.1.3-6linaro1.tar.gz
Source79:       v14.1_Firmware.zip
Source80:       xcb-proto-1.13.tar.bz2
Source81:       xkbcomp-1.4.2.tar.bz2
Source82:       xkeyboard-config-2.23.1.tar.bz2
Source83:       XML-Parser-2.44.tar.gz
Source84:       xorgproto-2018.4.tar.bz2
Source85:       xtrans-1.4.0.tar.bz2
Source86:       xz-5.2.4.tar.bz2
Source87:       zd1211-firmware-1.4.tar.bz2
Source88:       zlib-1.2.11.tar.xz

BuildRequires:	unzip
BuildRequires:  glibc glibc-32bit glibc-devel glibc-devel-32bit
BuildRequires:	autoconf >= 2.69 automake >= 1.15 bc bison cpio
%if 0%{?sle_version} == 120300 && 0%{?is_opensuse}
BuildRequires:	gcc gcc-32bit gcc-c++
BuildRequires:	python-argparse
%else
BuildRequires:	gcc gcc-32bit gcc-c++
%endif
BuildRequires:  oss-base
BuildRequires:	flex gettext git freetype2-devel libtool 
BuildRequires:	libopenssl-devel ncurses-devel python rsync texinfo unzip wget efont-unicode
BuildRequires:  cmake quilt
BuildRequires:	make >= 4.0

BuildRoot:    %{_tmppath}/%{name}-root
Requires:	oss-base logrotate wakeonlan BitTorrent BitTorrent-curses syslinux6 xorriso >= 1.2.4
Requires(post):	%insserv_prereq %fillup_prereq dropbear pwgen

PreReq: %insserv_prereq oss-base


%description
This package provides a boot environment based on linux installation and boot environment (linbo) for cloning clients.

Authors:
--------
        see readme

%prep
%setup -D

%build
export FORCE_UNSAFE_CONFIGURE=1
export BR2_DL_DIR=%{_sourcedir}
make -f rpm/Makefile build

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
# linbo kernels, initrds
mkdir -p %{buildroot}/usr/share/linbo/initrd
install build/build-i386/images/bzImage %{buildroot}/srv/tftp/linbo
install build/build-i386/images/bzImage.md5 %{buildroot}/srv/tftp/linbo.md5
install build/build-i386/images/rootfs.cpio.lz %{buildroot}/usr/share/linbo/initrd/linbofs.lz
touch %{buildroot}/srv/tftp/linbofs.lz
touch %{buildroot}/srv/tftp/linbofs.lz.md5
install build/build-x86_64/images/bzImage %{buildroot}/srv/tftp/linbo64
install build/build-x86_64/images/bzImage.md5 %{buildroot}/srv/tftp/linbo64.md5
install build/build-x86_64/images/rootfs.cpio.lz %{buildroot}/usr/share/linbo/initrd/linbofs64.lz
touch %{buildroot}/srv/tftp/linbofs64.lz
touch %{buildroot}/srv/tftp/linbofs64.lz.md5
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
%config(noreplace) /srv/tftp/boot/grub/grub.cfg
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
%ghost /srv/tftp/linbofs.lz
%ghost /srv/tftp/linbofs.lz.md5
/srv/tftp/linbo64
%attr(0644,root,root) /srv/tftp/linbo64.md5
%ghost /srv/tftp/linbofs64.lz
%ghost /srv/tftp/linbofs64.lz.md5
/srv/tftp/examples
/srv/tftp/linuxmuster-win
/srv/tftp/linbo-version
/usr/share/linbo
/usr/share/doc/packages/oss-linbo
%defattr(0755,root,root)
/usr/sbin/linbo-ssh
/usr/sbin/linbo-scp
/usr/sbin/linbo-remote
/usr/sbin/update-linbofs
/usr/bin/linbo-grub-mkimage
/usr/bin/linbo-grub-mkstandalone

%changelog
