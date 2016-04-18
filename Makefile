#!/usr/bin/make -f
#
# Dieses Makefile ruft die anderen Makefiles auf und sammelt schließlich alle
# Dateien aus den sysroot-Verzeichnissen ein.
#
# Frank Schütte
# 2016
# GPL v3
#

include common.mk

CURDIR=$(shell pwd)

# grub required modules
GRUB_COMMON_MODULES=all_video chain configfile cpuid echo net ext2 extcmd fat gettext gfxmenu gfxterm http \
 ntfs linux loadenv minicmd net part_gpt part_msdos png progress reiserfs search terminal test

GRUB_EFI32_MODULES=efi_gop efi_uga efinet tftp
GRUB_EFI64_MODULES=efi_gop efi_uga efinet linuxefi tftp

GRUB_PC_MODULES=biosdisk ntldr pxe

# common
DIRS = linbo_gui

CONFIGDIRS=$(DIRS:%=config-%)
BUILDDIRS=$(DIRS:%=build-%)
CLEANDIRS=$(DIRS:%=clean-%)
DISTCLEANDIRS=$(DIRS:%=distclean-%)
INSTALLDIRS=$(DIRS:%=install-%)

# sub makefiles
SUBS = sysroot tools

CONFIGSUBS=$(SUBS:%=config-%)
BUILDSUBS=$(SUBS:%=build-%)
CLEANSUBS=$(SUBS:%=clean-%)
DISTCLEANSUBS=$(SUBS:%=distclean-%)
INSTALLSUBS=$(SUBS:%=install-%)

# targets

all: build

install-kernel:
	make -f Makefile.kernel install

configure-toolchain32:
	# setup 32bit build tool chain
	mkdir -p $(TOOLCHAIN)
	cp -f /usr/bin/ar $(TOOLCHAIN)/i386-linux-gnu-ar
	cp -f /usr/bin/strip $(TOOLCHAIN)/i386-linux-gnu-strip

$(CONFIGDIRS): configure-toolchain32
	make -C $(@:config-%=%) configure

$(CONFIGSUBS): configure-toolchain32 install-kernel
	make -f Makefile.$(@:config-%=%) configure

configure: configure-stamp configure-toolchain32 $(CONFIGSUBS) $(CONFIGDIRS)
configure-stamp:
	touch configure-stamp

$(BUILDDIRS):
	make -C $(@:build-%=%) build

$(BUILDSUBS):
	make -f Makefile.$(@:build-%=%) build

build: build-stamp $(BUILDSUBS) $(BUILDDIRS)

build-stamp: configure-stamp
	touch build-stamp

$(CLEANDIRS):
	make -C $(@:clean-%=%) clean

$(CLEANSUBS):
	make -f Makefile.$(@:clean-%=%) clean
	make -f Makefile.kernel clean

$(DISTCLEANDIRS):
	make -C $(@:distclean-%=%) distclean

$(DISTCLEANSUBS):
	make -f Makefile.$(@:distclean-%=%) distclean
	make -f Makefile.kernel distclean

distclean: clean $(DISTCLEANSUBS) $(DISTCLEANDIRS)

clean: $(CLEANSUBS) $(CLEANDIRS)
	rm -f build-stamp configure-stamp $(TOOLCHAIN)/i386-linux-gnu-ar $(TOOLCHAIN)/i386-linux-gnu-strip
	rm -rf $(BUILDDIR)/boot

$(INSTALLDIRS):
	make -C $(@:install-%=%) install

$(INSTALLSUBS):
	make -f Makefile.$(@:install-%=%) install

install: $(INSTALLSUBS) $(INSTALLDIRS) install-initrd install-grubnetdir

install-initrd: $(SYSROOT)/linbofs.lz $(SYSROOT64)/linbofs64.lz

$(SYSROOT)/linbofs.lz:
	echo "LINBO $(LVERS)" > linbo/etc/linbo-version
	@echo "[1mBuilding LINBOFS...[0m"
	cat $(CURDIR)/conf/initramfs.conf > $(BUILDDIR)/initramfs.conf
	echo >> $(BUILDDIR)/initramfs.conf
	echo "# grub2 boot images" >> $(BUILDDIR)/initramfs.conf
	cd $(SYSROOT); find usr/lib/grub/i386-pc usr/lib/grub/i386-efi \
		-maxdepth 1 -name "*" -type f -printf "file /%p $(SYSROOT)/%p %m 0 0\n" >>$(BUILDDIR)/initramfs.conf
	echo "# udev" >> $(BUILDDIR)/initramfs.conf
	find /etc/udev -type d -printf "dir /%p %m 0 0\n" >>$(BUILDDIR)/initramfs.conf
	find /etc/udev -type f -printf "file /%p /%p %m 0 0\n" >>$(BUILDDIR)/initramfs.conf
	cd $(SYSROOT); find lib/udev -type d -printf "dir /%p %m 0 0\n" >>$(BUILDDIR)/initramfs.conf
	cd $(SYSROOT); find lib/udev -type f -printf "file /%p $(SYSROOT)/%p %m 0 0\n" >>$(BUILDDIR)/initramfs.conf
	echo "# modules" >> $(BUILDDIR)/initramfs.conf
	cd $(SYSROOT); find lib/modules -type d -printf "dir /%p %m 0 0\n" >>$(BUILDDIR)/initramfs.conf
	cd $(SYSROOT); find lib/modules -type f -printf "file /%p $(SYSROOT)/%p %m 0 0\n" >>$(BUILDDIR)/initramfs.conf
	echo >> $(BUILDDIR)/initramfs.conf
	echo "# busybox applets" >> $(BUILDDIR)/initramfs.conf
	cd $(BUILDBB32); find _install -type d -printf "dir %p %m 0 0\n" | sed 's@_install@@' >>$(BUILDDIR)/initramfs.conf
	cd $(BUiLDBB32); find _install -type l -printf "slink %p /bin/busybox 777 0 0\n" | sed 's@_install@@' >>$(BUILDDIR)/initramfs.conf
	rm -f $(SYSROOT)/linbofs.lz; $(SYSROOT)/usr/gen_init_cpio $(BUILDDIR)/initramfs.conf | lzma -zcv > $(SYSROOT)/linbofs.lz

$(SYSROOT64)/linbofs64.lz:
	echo "LINBO $(LVERS)" > linbo/etc/linbo-version
	@echo "[1mBuilding 64bit LINBOFS...[0m"
	cat $(CURDIR)/conf/initramfs.conf > $(BUILDDIR)/initramfs64.conf
	echo >> $(BUILDDIR)/initramfs64.conf
	echo "# grub2 boot images" >> $(BUILDDIR)/initramfs64.conf
	cd $(SYSROOT64); find usr/lib/grub/i386-pc usr/lib/grub/i386-efi \
		-maxdepth 1 -name "*" -type f -printf "file /%p $(SYSROOT64)/%p %m 0 0\n" >>$(BUILDDIR)/initramfs64.conf
	echo "# udev" >> $(BUILDDIR)/initramfs64.conf
	find /etc/udev -type d -printf "dir /%p %m 0 0\n" >>$(BUILDDIR)/initramfs64.conf
	find /etc/udev -type f -printf "file /%p /%p %m 0 0\n" >>$(BUILDDIR)/initramfs64.conf
	cd $(SYSROOT64); find lib/udev -type d -printf "dir /%p %m 0 0\n" >>$(BUILDDIR)/initramfs64.conf
	cd $(SYSROOT64); find lib/udev -type f -printf "file /%p $(SYSROOT64)/%p %m 0 0\n" >>$(BUILDDIR)/initramfs64.conf
	echo "# modules" >> $(BUILDDIR)/initramfs64.conf
	cd $(SYSROOT64); find lib/modules -type d -printf "dir /%p %m 0 0\n" >>$(BUILDDIR)/initramfs64.conf
	cd $(SYSROOT64); find lib/modules -type f -printf "file /%p $(SYSROOT64)/%p %m 0 0\n" >>$(BUILDDIR)/initramfs64.conf
	echo >> $(BUILDDIR)/initramfs64.conf
	echo "# busybox applets" >> $(BUILDDIR)/initramfs64.conf
	cd $(BUILDBB64); find _install -type d -printf "dir %p %m 0 0\n" | sed 's@_install@@' >>$(BUILDDIR)/initramfs64.conf
	cd $(BUiLDBB64); find _install -type l -printf "slink %p /bin/busybox 777 0 0\n" | sed 's@_install@@' >>$(BUILDDIR)/initramfs64.conf
	rm -f $(SYSROOT64)/linbofs64.lz; $(SYSROOT64)/usr/gen_init_cpio $(BUILDDIR)/initramfs.conf | lzma -zcv > $(SYSROOT64)/linbofs64.lz

install-grubnetdir: $(SYSROOT64)/usr/lib/grub/i386-pc $(SYSROOT)/usr/lib/grub/i386-efi $(SYSROOT64)/usr/lib/grub/x86_64-efi
	grub-mknetdir --modules="$(GRUB_PC_MODULES) $(GRUB_COMMON_MODULES)" -d $(SYSROOT64)/usr/lib/grub/i386-pc --net-directory=$(BUILDDIR) --subdir=/boot/grub
	grub-mknetdir --modules="$(GRUB_EFI32_MODULES) $(GRUB_COMMON_MODULES)" -d $(SYSROOT)/usr/lib/grub/i386-efi --net-directory=$(BUILDDIR) --subdir=/boot/grub
	grub-mknetdir --modules="$(GRUB_EFI64_MODULES) $(GRUB_COMMON_MODULES)" -d $(SYSROOT64)/usr/lib/grub/x86_64-efi --net-directory=$(BUILDDIR) --subdir=/boot/grub

.PHONY: subdirs $(DIRS)
.PHONY: subdirs $(BUILDDIRS)
.PHONY: subdirs $(CONFIGDIRS)
.PHONY: subdirs $(CLEANDIRS)
.PHONY: $(CONFIGSUBS) $(BUILDSUBS) $(CLEANSUBS) $(INSTALLSUBS)
.PHONY: build clean install install-kernel install-grubnetdir configure
