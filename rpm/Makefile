# Makefile
# Wir haben einen Rechner, der per PXE werder GRUB-2.02~rc2 noch ein kompiliertes GRUB-2.02~rc2
# noch den GRUB aus dem Ubuntu-Paket bootet, weshalb hier nochmal ein funktionierender GRUB gebaut wird.
BUILDROOT=$(CURDIR)/buildroot
BUILDDIR=$(CURDIR)/build
BUILD32=$(BUILDDIR)/build-i386
BUILD64=$(BUILDDIR)/build-x86_64
LINBO_VERSION=$(shell cat rpm/oss-linbo.spec | grep '^Version:' | awk '{ print $$2 }')
LINBO_RELEASE=$(shell cat rpm/oss-linbo.spec | grep '^Release:' | awk '{ print $$2 }')

GRUBNAME=grub-2.02~rc2
GRUBCFG=--disable-nls --disable-efiemu --disable-mm-debug --disable-cache-stats \
 --disable-boot-time --disable-grub-mkfont \
 --disable-grub-mount --disable-device-mapper --disable-liblzma --disable-libzfs
GRUB_COMMON_MODULES=all_video chain configfile cpuid echo net ext2 extcmd \
 fat gettext gfxmenu gfxterm http ntfs linux loadenv minicmd net part_gpt \
 part_msdos png progress reiserfs search terminal test
GRUB_ISO_MODULES=iso9660 usb
GRUB_PC_MODULES=biosdisk ntldr pxe
GRUB_EFI_MODULES=efi_gop efi_uga efinet tftp
GRUB_MKNETDIR=$(BUILDDIR)/grub-pc-i386/grub-mknetdir --net-directory=$(BUILDDIR) --subdir=/boot/grub
ifeq ("$(BR2_DL_DIR)","")
	BR2_DL_DIR=$(BUILDROOT)/dl
endif

clean:
	rm -rf build/

.PHONY: build-linbo build-grub build

build-linbo:
	echo "LINBO $(LINBO_VERSION)-$(LINBO_RELEASE)" >linbofs/etc/linbo-version
	cd $(BUILDROOT); make O=$(BUILD32) BR2_EXTERNAL=$(BUILDROOT)-external linbo-i386_defconfig
	cd $(BUILDROOT); make O=$(BUILD64) BR2_EXTERNAL=$(BUILDROOT)-external linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD32)
	cd $(BUILDROOT); make O=$(BUILD64)

$(BUILDDIR)/$(GRUBNAME)/configure: $(BR2_DL_DIR)/$(GRUBNAME).tar.gz
	cd $(BUILDDIR); tar xf $(BR2_DL_DIR)/$(GRUBNAME).tar.gz;

$(BUILDDIR)/grub-pc-i386/configure: $(BUILDDIR)/$(GRUBNAME)/configure
	cd $(BUILDDIR); cp -a $(GRUBNAME) grub-pc-i386;

$(BUILDDIR)/grub-efi-i386/configure: $(BUILDDIR)/$(GRUBNAME)/configure
	cd $(BUILDDIR); cp -a $(GRUBNAME) grub-efi-i386;

$(BUILDDIR)/grub-efi-x86_64/configure: $(BUILDDIR)/$(GRUBNAME)/configure
	cd $(BUILDDIR); cp -a $(GRUBNAME) grub-efi-x86_64

$(BUILDDIR)/grub-pc-i386/grub-mknetdir: $(BUILDDIR)/grub-pc-i386/configure
	cd $(BUILDDIR)/grub-pc-i386; ./configure $(GRUBCFG) --with-platform=pc --target=i386; make

$(BUILDDIR)/grub-efi-i386/grub-mknetdir: $(BUILDDIR)/grub-efi-i386/configure
	cd $(BUILDDIR)/grub-efi-i386; ./configure $(GRUBCFG) --with-platform=efi --target=i386; make

$(BUILDDIR)/grub-efi-x86_64/grub-mknetdir: $(BUILDDIR)/grub-efi-x86_64/configure
	cd $(BUILDDIR)/grub-efi-x86_64; ./configure $(GRUBCFG) --with-platform=efi --target=x86_64; make

build-grub: $(BUILDDIR)/grub-pc-i386/grub-mknetdir $(BUILDDIR)/grub-efi-i386/grub-mknetdir $(BUILDDIR)/grub-efi-x86_64/grub-mknetdir
	$(GRUB_MKNETDIR) --modules="$(GRUB_COMMON_MODULES) $(GRUB_PC_MODULES)" -d $(BUILDDIR)/grub-pc-i386/grub-core
	# make core.iso
	$(GRUB_MKNETDIR) --modules="$(GRUB_COMMON_MODULES) $(GRUB_EFI_MODULES) $(GRUB_ISO_MODULES)" -d $(BUILDDIR)/grub-efi-i386/grub-core
	$(GRUB_MKNETDIR) --modules="$(GRUB_COMMON_MODULES) $(GRUB_EFI_MODULES) $(GRUB_ISO_MODULES)" -d $(BUILDDIR)/grub-efi-x86_64/grub-core
	mv $(BUILDDIR)/boot/grub/i386-efi/core.efi $(BUILDDIR)/boot/grub/i386-efi/core.iso
	mv $(BUILDDIR)/boot/grub/x86_64-efi/core.efi $(BUILDDIR)/boot/grub/x86_64-efi/core.iso
	# make core.efi
	$(GRUB_MKNETDIR) --modules="$(GRUB_COMMON_MODULES) $(GRUB_EFI_MODULES)" -d $(BUILDDIR)/grub-efi-i386/grub-core
	$(GRUB_MKNETDIR) --modules="$(GRUB_COMMON_MODULES) $(GRUB_EFI_MODULES)" -d $(BUILDDIR)/grub-efi-x86_64/grub-core

build: build-linbo build-grub
