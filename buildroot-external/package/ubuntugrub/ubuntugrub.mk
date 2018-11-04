################################################################################
#
# ubuntugrub
#
################################################################################

UBUNTUGRUB_VERSION = 2.02
UBUNTUGRUB_SITE = http://archive.ubuntu.com/ubuntu/pool/main/g/grub2
UBUNTUGRUB_SOURCE = grub2_$(UBUNTUGRUB_VERSION).orig.tar.xz
UBUNTUGRUB_EXTRA_DOWNLOADS = grub2_$(UBUNTUGRUB_VERSION)-2ubuntu8.debian.tar.xz
UBUNTUGRUB_LICENSE = GPLv3
UBUNTUGRUB_LICENSE_FILES = COPYING

UBUNTUGRUB_CONF_ENV = \
	CPP="$(TARGET_CC) -E"
UBUNTUGRUB_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --disable-grub-mkfont \
	--disable-grub-mount --disable-device-mapper --disable-emu-usb \
	--disable-liblzma --disable-libzfs --disable-grub-themes

UBUNTUGRUB_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"
# Fix: old gcc don't have this option - enable for gcc-6
# UBUNTUGRUB_CONF_OPTS += LDFLAGS="-no-pie"

# REAL_PACKAGES = grub-pc(grub-pc-i386) grub-efi-ia32(-i386) grub-efi-amd64(-x86_64)
# COMMON_PLATFORM := pc
# DEFAULT_CMDLINE := quiet
# DEFAULT_TIMEOUT := 5
# FLICKER_FREE_BOOT := no
# DEFAULT_HIDDEN_TIMEOUT :=
# DEFAULT_HIDDEN_TIMEOUT_BOOL := false

# extract debian dir
define UBUNTUGRUB_EXTRACT_DEBIAN
    for file in $(UBUNTUGRUB_EXTRA_DOWNLOADS); do \
	xzcat $(BR2_DL_DIR)/$$file | tar -C $(UBUNTUGRUB_SRCDIR)   -xf - ; \
    done
endef

UBUNTUGRUB_POST_EXTRACT_HOOKS += UBUNTUGRUB_EXTRACT_DEBIAN

# apply patches
define UBUNTUGRUB_APPLY_DEBIAN_PATCHES
    (cd $(UBUNTUGRUB_SRCDIR) && \
    QUILT_PATCHES="debian/patches" QUILT_SERIES="debian/patches/series" quilt push -a \
    )
endef

UBUNTUGRUB_POST_PATCH_HOOKS += UBUNTUGRUB_APPLY_DEBIAN_PATCHES

# autoreconf
define UBUNTUGRUB_POST_PATCH
	(cd $(UBUNTUGRUB_SRCDIR) && \
	rm -rf debian/grub-extras-enabled && \
	mkdir debian/grub-extras-enabled && \
	set -e; for extra in 915resolution ntldr-img; do \
		cp -a debian/grub-extras/$$extra debian/grub-extras-enabled/; \
	done && \
	$(TARGET_CONFIGURE_OPTS) \
	GRUB_CONTRIB=$(UBUNTUGRUB_SRCDIR)debian/grub-extras-enabled \
	./autogen.sh \
	)
endef

UBUNTUGRUB_POST_PATCH_HOOKS += UBUNTUGRUB_POST_PATCH

UBUNTUGRUB_PACKAGES = grub-pc-i386 grub-efi-i386
ifeq ($(BR2_x86_64),y)
UBUNTUGRUB_PACKAGES += grub-efi-x86_64
endif

# configure
define UBUNTUGRUB_CONFIGURE_CMDS
	for package in $(UBUNTUGRUB_PACKAGES); do \
		mkdir -p $(UBUNTUGRUB_SRCDIR)obj/$$package; \
	(cd $(UBUNTUGRUB_SRCDIR)obj/$$package && rm -rf config.cache && \
	$(TARGET_CONFIGURE_OPTS) \
	$(TARGET_CONFIGURE_ARGS) \
	$(UBUNTUGRUB_CONF_ENV) \
	CONFIG_SITE=/dev/null \
	../../configure \
		--with-platform=$$(echo $$package|sed 's/^grub-//'|sed 's/-[^-]*$$//') \
		--target=$$(echo $$package|sed 's/^grub-//'|sed 's/^[^-]*-//') \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--program-prefix="" \
		$(if $(UBUNTUGRUB_OVERRIDE_SRCDIR),,--disable-dependency-tracking) \
		--enable-ipv6 \
		$(NLS_OPTS) \
		$(SHARED_STATIC_LIBS_OPTS) \
		$(QUIET) $(UBUNTUGRUB_CONF_OPTS) \
	) \
	done
endef

# build
define UBUNTUGRUB_BUILD_CMDS
	for package in $(UBUNTUGRUB_PACKAGES); do \
		$(TARGET_MAKE_ENV) $(UBUNTUGRUB_MAKE_ENV) $(UBUNTUGRUB_MAKE) \
		$(UBUNTUGRUB_MAKE_OPTS) -C $(UBUNTUGRUB_SRCDIR)obj/$$package; \
	done
endef

# install
define UBUNTUGRUB_INSTALL_TARGET_CMDS
	for package in $(UBUNTUGRUB_PACKAGES); do \
		$(TARGET_MAKE_ENV) $(UBUNTUGRUB_MAKE_ENV) $(UBUNTUGRUB_MAKE) \
		$(UBUNTUGRUB_INSTALL_TARGET_OPTS) -C $(UBUNTUGRUB_SRCDIR)obj/$$package; \
	done
endef

define UBUNTUGRUB_CLEANUP
	for arch in i386-pc i386-efi x86_64-efi; do \
		rm -fv $(TARGET_DIR)/usr/lib/grub/$$arch/*.image $(TARGET_DIR)/usr/lib/grub/$$arch/*.module \
		$(TARGET_DIR)/usr/lib/grub/$$arch/kernel.exec $(TARGET_DIR)/usr/lib/grub/$$arch/gdb_grub \
		$(TARGET_DIR)/usr/lib/grub/$$arch/gmodule.pl $(TARGET_DIR)/etc/bash_completion.d/grub; \
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
UBUNTUGRUB_BIN_ARCH_EXCLUDE += /usr/lib/grub
endif

################################################################################
#
# host-ubuntugrub
#
################################################################################

# common modules
HOST_UBUNTUGRUB_COMMON_MODS=all_video chain configfile cpuid echo net ext2 extcmd fat gettext gfxmenu gfxterm http \
 ntfs linux loadenv minicmd net part_gpt part_msdos png progress reiserfs search terminal test tftp
# modules needed for cd/usb boot
HOST_UBUNTUGRUB_ISO_MODS=iso9660 usb

# arch specific netboot modules
HOST_UBUNTUGRUB_EFI32_MODS=$(HOST_UBUNTUGRUB_COMMON_MODS) efi_gop efi_uga efinet
HOST_UBUNTUGRUB_EFI64_MODS=$(HOST_UBUNTUGRUB_COMMON_MODS) efi_gop efi_uga efinet linuxefi
HOST_UBUNTUGRUB_I386_MODS=$(HOST_UBUNTUGRUB_COMMON_MODS) biosdisk ntldr pxe

HOST_UBUNTUGRUB_FONT = unicode

HOST_UBUNTUGRUB_CONF_ENV = \
	CPP="$(HOSTCC) -E"

# TODO: --enable-grub-mkfont not working, it's not detected properly by configure
HOST_UBUNTUGRUB_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --disable-grub-mkfont \
	--disable-grub-mount --disable-device-mapper --disable-emu-usb \
	--disable-liblzma --disable-libzfs --disable-grub-themes

HOST_UBUNTUGRUB_CONF_OPTS += CFLAGS="$(HOST_CFLAGS) -Wno-error"
# Fix: old gcc don't have this option - enable for gcc-6
# HOST_UBUNTUGRUB_CONF_OPTS += LDFLAGS="-no-pie"


# extract debian dir
define HOST_UBUNTUGRUB_EXTRACT_DEBIAN
    for file in $(UBUNTUGRUB_EXTRA_DOWNLOADS); do \
	xzcat $(BR2_DL_DIR)/$$file | tar -C $(HOST_UBUNTUGRUB_SRCDIR)   -xf - ; \
    done
endef

HOST_UBUNTUGRUB_POST_EXTRACT_HOOKS += HOST_UBUNTUGRUB_EXTRACT_DEBIAN

# apply patches
define HOST_UBUNTUGRUB_APPLY_DEBIAN_PATCHES
    (cd $(HOST_UBUNTUGRUB_SRCDIR) && \
    QUILT_PATCHES="debian/patches" QUILT_SERIES="debian/patches/series" quilt push -a \
    )
endef

HOST_UBUNTUGRUB_POST_PATCH_HOOKS += HOST_UBUNTUGRUB_APPLY_DEBIAN_PATCHES

# autoreconf
define HOST_UBUNTUGRUB_POST_PATCH
	(cd $(HOST_UBUNTUGRUB_SRCDIR) && \
	rm -rf debian/grub-extras-enabled && \
	mkdir debian/grub-extras-enabled && \
	set -e; for extra in 915resolution ntldr-img; do \
		cp -a debian/grub-extras/$$extra debian/grub-extras-enabled/; \
	done && \
	$(HOST_CONFIGURE_OPTS) \
	GRUB_CONTRIB=$(HOST_UBUNTUGRUB_SRCDIR)debian/grub-extras-enabled \
	./autogen.sh \
	)
endef

HOST_UBUNTUGRUB_POST_PATCH_HOOKS += HOST_UBUNTUGRUB_POST_PATCH

HOST_UBUNTUGRUB_PACKAGES = grub-pc-i386 grub-efi-i386 grub-efi-x86_64

# configure
define HOST_UBUNTUGRUB_CONFIGURE_CMDS
	for package in $(HOST_UBUNTUGRUB_PACKAGES); do \
		mkdir -p $(HOST_UBUNTUGRUB_SRCDIR)obj/$$package; \
	(cd $(HOST_UBUNTUGRUB_SRCDIR)obj/$$package && rm -rf config.cache && \
	$(HOST_CONFIGURE_OPTS) \
	CFLAGS="$(HOST_CFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)" \
	$(HOST_UBUNTUGRUB_CONF_ENV) \
	CONFIG_SITE=/dev/null \
	../../configure \
		--with-platform=$$(echo $$package|sed 's/^grub-//'|sed 's/-[^-]*$$//') \
		--target=$$(echo $$package|sed 's/^grub-//'|sed 's/^[^-]*-//') \
		--prefix="$(HOST_DIR)" \
		--sysconfdir="$(HOST_DIR)/etc" \
		--localstatedir="$(HOST_DIR)/var" \
		--enable-shared --disable-static \
		--disable-debug \
		$(if $(HOST_UBUNTUGRUB_OVERRIDE_SRCDIR),,--disable-dependency-tracking) \
		$(QUIET) $(HOST_UBUNTUGRUB_CONF_OPTS) \
	) \
	done
endef

# build
define HOST_UBUNTUGRUB_BUILD_CMDS
	for package in $(HOST_UBUNTUGRUB_PACKAGES); do \
		$(HOST_MAKE_ENV) $(HOST_UBUNTUGRUB_MAKE_ENV) $(HOST_UBUNTUGRUB_MAKE) \
		$(HOST_UBUNTUGRUB_MAKE_OPTS) -C $(HOST_UBUNTUGRUB_SRCDIR)obj/$$package; \
	done
endef

# install
define HOST_UBUNTUGRUB_INSTALL_CMDS
	for package in $(HOST_UBUNTUGRUB_PACKAGES); do \
		$(HOST_MAKE_ENV) $(HOST_UBUNTUGRUB_MAKE_ENV) $(HOST_UBUNTUGRUB_MAKE) \
		$(HOST_UBUNTUGRUB_INSTALL_OPTS) -C $(HOST_UBUNTUGRUB_SRCDIR)obj/$$package; \
	done
endef

define HOST_UBUNTUGRUB_MKNETDIR
	mkdir -p $(HOST_DIR)/usr/share/grub
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
		--modules="$(HOST_UBUNTUGRUB_I386_MODS)" \
		-d $(HOST_DIR)/lib/grub/i386-pc
# Grub2 EFI32 netdir creation
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_EFI32_MODS) $(HOST_UBUNTUGRUB_ISO_MODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
	mv $(BASE_DIR)/boot/grub/i386-efi/core.efi $(BASE_DIR)/boot/grub/i386-efi/core.iso
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_EFI32_MODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
# Grub2 EFI64 netdir creation
	mkdir -p $(BASE_DIR)/boot/grub
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_EFI64_MODS) $(HOST_UBUNTUGRUB_ISO_MODS)" \
		-d $(HOST_DIR)/lib/grub/x86_64-efi
	mv $(BASE_DIR)/boot/grub/x86_64-efi/core.efi $(BASE_DIR)/boot/grub/x86_64-efi/core.iso
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_UBUNTUGRUB_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_UBUNTUGRUB_EFI64_MODS)" \
		-d $(HOST_DIR)/lib/grub/x86_64-efi
endef

HOST_UBUNTUGRUB_POST_INSTALL_HOOKS += HOST_UBUNTUGRUB_MKNETDIR

$(eval $(autotools-package))
$(eval $(host-autotools-package))
