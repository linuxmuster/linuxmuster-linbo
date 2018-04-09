################################################################################
#
# ubuntugrub
#
################################################################################

UBUNTUGRUB_VERSION = 2.02
UBUNTUGRUB_SITE = $(TOPDIR)/../rpm
UBUNTUGRUB_SOURCE = grub-bin.tar.gz
UBUNTUGRUB_SITE_METHOD = file
UBUNTUGRUB_ACTUAL_SOURCE_TARBALL = grub-$(UBUNTUGRUB_VERSION).tar.gz
UBUNTUGRUB_ACTUAL_SOURCE_SITE = https://ftp.gnu.org/gnu/grub
UBUNTUGRUB_LICENSE = GPLv3
UBUNTUGRUB_LICENSE_FILES = COPYING

UBUNTUGRUB_CONF_ENV = \
	CPP="$(TARGET_CC) -E"
UBUNTUGRUB_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --enable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper --disable-emu-usb \
	--enable-ubuntu-recovery \
	--disable-liblzma --disable-libzfs

UBUNTUGRUB_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"
UBUNTUGRUB_CONF_OPTS += CC=gcc-6 LDFLAGS="-no-pie"

# REAL_PACKAGES = grub-pc(grub-pc-i386) grub-efi-ia32(-i386) grub-efi-amd64(-x86_64)
# COMMON_PLATFORM := pc
# DEFAULT_CMDLINE := quiet
# DEFAULT_TIMEOUT := 5
# FLICKER_FREE_BOOT := no
# DEFAULT_HIDDEN_TIMEOUT :=
# DEFAULT_HIDDEN_TIMEOUT_BOOL := false

# autoreconf
define UBUNTUGRUB_POST_PATCH
	(cd $$(UBUNTUGRUB_SRCDIR) && \
	rm -rf debian/grub-extras-enabled && \
	mkdir debian/grub-extras-enabled && \
	set -e; for extra in 915resolution ntldr-img; do \
		cp -a debian/grub-extras/$$extra debian/grub-extras-enabled/; \
	done \
	)
endef

UBUNTUGRUB_POST_PATCH_HOOKS += UBUNTUGRUB_POST_PATCH

UBUNTUGRUB_AUTORECONF=YES
UBUNTUGRUB_AUTORECONF_ENV="GRUB_CONTRIB=$(@D)/debian/grub-extras-enabled"

UBUNTUGRUB_PACKAGES=grub-pc-i386 grub-efi-i386
ifeq ($(BR2_x86_64),y)
UBUNTUGRUB_PACKAGES += grub-efi-x86_64
endif

# configure
define UBUNTUGRUB_CONFIGURE_CMDS
	for package in $(UBUNTUGRUB_PACKAGES); do \
		mkdir -p $$(UBUNTUGRUB_SRCDIR)/obj/$$(package); \
	(cd $$(UBUNTUGRUB_SRCDIR)/obj/$$(package) && rm -rf config.cache && \
	$$(TARGET_CONFIGURE_OPTS) \
	$$(TARGET_CONFIGURE_ARGS) \
	$$($$(PKG)_CONF_ENV) \
	CONFIG_SITE=/dev/null \
	../../configure \
		--with-platform=$(subst grub-%-*,%,$$(package)) \
		--target=$(subst grub-*-%,%,$$(package)) \
		--host=$$(GNU_TARGET_NAME) \
		--build=$$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--program-prefix="" \
		--disable-gtk-doc \
		--disable-gtk-doc-html \
		--disable-doc \
		--disable-docs \
		--disable-documentation \
		--with-xmlto=no \
		--with-fop=no \
		$$(if $$(UBUNTUGRUB_OVERRIDE_SRCDIR),,--disable-dependency-tracking) \
		--enable-ipv6 \
		$$(NLS_OPTS) \
		$$(SHARED_STATIC_LIBS_OPTS) \
		$$(QUIET) $$(UBUNTUGRUB_CONF_OPTS) \
	) \
	done
endef

# build
define UBUNTUGRUB_BUILD_CMDS
	for package in $(UBUNTUGRUB_PACKAGES); do \
		$$(TARGET_MAKE_ENV) $$(UBUNTUGRUB_MAKE_ENV) $$(UBUNTUGRUB_MAKE) \
		$$(UBUNTUGRUB_MAKE_OPTS) -C $$(UBUNTUGRUB_SRCDIR)/obj/$$(package) \
	done
endef

# install
define UBUNTUGRUB_INSTALL_TARGET_CMDS
	for package in $(UBUNTUGRUB_PACKAGES); do \
		$$(TARGET_MAKE_ENV) $$(UBUNTUGRUB_MAKE_ENV) $$(UBUNTUGRUB_MAKE) \
		$$(UBUNTUGRUB_INSTALL_TARGET_OPTS) -C $$(UBUNTUGRUB_SRCDIR)/obj/$$(package) \
	done
endef

define UBUNTUGRUB_CLEANUP
	for arch in i386-pc i386-efi x86_64-efi; do \
		rm -fv $(TARGET_DIR)/usr/lib/grub/$$(arch)/*.image $(TARGET_DIR)/usr/lib/grub/$$(arch)/*.module \
		$(TARGET_DIR)/usr/lib/grub/$$(arch)/kernel.exec $(TARGET_DIR)/usr/lib/grub/$$(arch)/gdb_grub \
		$(TARGET_DIR)/usr/lib/grub/$$(arch)/gmodule.pl $(TARGET_DIR)/etc/bash_completion.d/grub; \
	done
	rmdir -v $(TARGET_DIR)/etc/bash_completion.d/
endef
UBUNTUGRUB_POST_INSTALL_TARGET_HOOKS += UBUNTUGRUB_CLEANUP

ifeq ($(BR2_x86_64),y)
UBUNTUGRUB_IMGS = boot boot_hybrid cdboot diskboot kernel lnxboot lzma_decompress pxeboot
UBUNTUGRUB_MODS = \
	915resolution acpi adler32 affs afs ahci all_video aout appleldr archelp ata at_keyboard backtrace bfs biosdisk bitmap bitmap_scale \
	blocklist boot bsd bswap_test btrfs bufio cat cbfs cbls cbmemc cbtable cbtime \
	chain cmdline_cat_test cmosdump cmostest cmp cmp_test configfile cpio_be cpio cpuid crc64 cryptodisk crypto \
	cs5536 ctz_test datehook date datetime diskfilter disk div div_test dm_nv drivemap echo efinet efi_gop efi_uga efiemu ehci elf eval \
	efifwsetup exfat exfctest ext2 extcmd fat file fixvideo font freedos fshelp functional_test gcry_arcfour gcry_blowfish gcry_camellia \
	gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_idea gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael gcry_rmd160 \
	gcry_rsa gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger gcry_twofish gcry_whirlpool \
	gdb geli gettext gfxmenu gfxterm_background gfxterm_menu gfxterm gptsync gzio halt hashsum hdparm hello help \
	hexdump hfs hfspluscomp hfsplus http hwmatch iorw iso9660 jfs jpeg keylayouts keystatus ldm legacycfg legacy_password_test \
	linux16 linux linuxefi loadbios loadenv loopback lsacpi lsapm lsefi lsefimmap lsefisystab lsmmap ls lspci lssal luks lvm lzopio macbless macho mda_text mdraid09_be \
	mdraid09 mdraid1x memdisk memrw minicmd minix2_be minix2 minix3_be minix3 minix_be minix mmap morse mpi msdospart \
	mul_test multiboot2 multiboot nativedisk net newc nilfs2 normal ntfscomp ntfs ntldr odc offsetio ohci part_acorn \
	part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool \
	password password_pbkdf2 pata pbkdf2 pbkdf2_test pcidump pci plan9 play png priority_queue probe procfs progress \
	pxechain pxe raid5rec raid6rec random read reboot regexp reiserfs relocator romfs scsi search_fs_file search_fs_uuid \
	search_label search sendkey serial setjmp setjmp_test setpci sfs shift_test signature_test sleep sleep_test \
	spem spkmodem squash4 syslinuxcfg tar terminal terminfo test_blockarg testload test testspeed tftp tga time trig tr truecrypt \
	true udf ufs1_be ufs1 ufs2 uhci usb_keyboard usb usbms usbserial_common usbserial_ftdi usbserial_pl2303 \
	usbserial_usbdebug usbtest vbe verify vga vga_text video_bochs video_cirrus video_colors video_fb videoinfo video \
	videotest_checksum videotest xfs xnu xnu_uuid xnu_uuid_test xzio zfscrypt zfsinfo zfs
UBUNTUGRUB_CHECK_BIN_ARCH_EXCLUSIONS = \
	$(patsubst %,/usr/lib/grub/i386-pc/%.mod,$(UBUNTUGRUB_MODS)) \
	$(patsubst %,/usr/lib/grub/i386-pc/%.img,$(UBUNTUGRUB_IMGS)) \
	/usr/lib/grub/i386-pc/efiemu32.o \
	$(patsubst %,/usr/lib/grub/i386-efi/%.mod,$(UBUNTUGRUB_MODS)) \
	$(patsubst %,/usr/lib/grub/i386-efi/%.img,$(UBUNTUGRUB_IMGS))
endif


ifeq ($(BR2_x86_64),y)
HOST_UBUNTUGRUB_DEPENDENCIES = host-lvm2
endif

HOST_UBUNTUGRUB_MODS = all_video boot chain configfile cpuid echo net ext2 extcmd fat \
	gettext gfxmenu gfxterm gzio http ntfs linux linux16 loadenv minicmd net part_gpt \
	part_msdos png progress read reiserfs search sleep terminal test tftp \
	biosdisk gfxterm_background normal ntldr pxe

HOST_UBUNTUGRUB_FONT = unicode

ifeq ($(BR2_x86_64),y)
define HOST_UBUNTUGRUB_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr
	cp -R $(@D)/* $(HOST_DIR)/usr
	cp $(HOST_DIR)/usr/bin64/* $(HOST_DIR)/usr/bin
	rm -rf $(HOST_DIR)/usr/bin32 $(HOST_DIR)/usr/bin64
# Grub2 install unicode font
	cp $(BASE_DIR)/../../linbofs/usr/share/grub/$(HOST_UBUNTUGRUB_FONT).pf2 $(HOST_DIR)/usr/share/grub/
# Grub2 BIOS netdir creation
	mkdir -p $(BASE_DIR)/boot/grub
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		-d $(HOST_DIR)/lib/grub/i386-pc
	mv $(BASE_DIR)/boot/grub/i386-pc/core.0 $(BASE_DIR)/boot/grub/i386-pc/core.min
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_MODS)" \
		-d $(HOST_DIR)/lib/grub/i386-pc
# Grub2 EFI32 netdir creation
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_MODS) $(HOST_UBUNTUGRUB_ISOMODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
	mv $(BASE_DIR)/boot/grub/i386-efi/core.efi $(BASE_DIR)/boot/grub/i386-efi/core.iso
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_MODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
# Grub2 EFI64 netdir creation
	mkdir -p $(BASE_DIR)/boot/grub
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_MODS) $(HOST_UBUNTUGRUB_ISOMODS)" \
		-d $(HOST_DIR)/lib/grub/x86_64-efi
	mv $(BASE_DIR)/boot/grub/x86_64-efi/core.efi $(BASE_DIR)/boot/grub/x86_64-efi/core.iso
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_MODS)" \
		-d $(HOST_DIR)/lib/grub/x86_64-efi
endef
else
define HOST_UBUNTUGRUB_INSTALL_CMDS
	echo "Nothing to do."
endef
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
