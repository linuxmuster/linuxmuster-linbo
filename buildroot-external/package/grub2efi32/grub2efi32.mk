################################################################################
#
# grub2efi32
#
################################################################################

GRUB2EFI32_VERSION = 2.02
GRUB2EFI32_SOURCE = grub-$(GRUB2EFI32_VERSION).tar.gz
GRUB2EFI32_SITE = ftp://ftp.gnu.org/gnu/grub
GRUB2EFI32_LICENSE = GPLv3
GRUB2EFI32_LICENSE_FILES = COPYING

GRUB2EFI32_CONF_ENV = \
	CPP="$(TARGET_CC) -E"
GRUB2EFI32_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --disable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper \
	--disable-liblzma --disable-libzfs --with-platform=efi --target=i386
GRUB2EFI32_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"

define GRUB2EFI32_CLEANUP
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/*.image
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/*.module
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/kernel.exec
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/gdb_grub
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/gmodule.pl
	rm -fv $(TARGET_DIR)/etc/bash_completion.d/grub
	rmdir -v $(TARGET_DIR)/etc/bash_completion.d/
endef
GRUB2EFI32_POST_INSTALL_TARGET_HOOKS += GRUB2EFI32_CLEANUP

ifeq ($(BR2_x86_64),y)
GRUB2EFI32_IMGS = boot boot_hybrid cdboot diskboot kernel lnxboot lzma_decompress pxeboot
GRUB2EFI32_MODS = \
	acpi adler32 affs afs ahci all_video aout archelp ata at_keyboard backtrace bfs biosdisk bitmap bitmap_scale \
	blocklist boot bsd bswap_test btrfs bufio cat cbfs cbls cbmemc cbtable cbtime \
	chain cmdline_cat_test cmosdump cmostest cmp cmp_test configfile cpio_be cpio cpuid crc64 cryptodisk crypto \
	cs5536 ctz_test datehook date datetime diskfilter disk div div_test dm_nv drivemap echo efiemu ehci elf eval \
	exfat exfctest ext2 extcmd fat file font freedos fshelp functional_test gcry_arcfour gcry_blowfish gcry_camellia \
	gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_idea gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael gcry_rmd160 \
	gcry_rsa gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger gcry_twofish gcry_whirlpool \
	gdb geli gettext gfxmenu gfxterm_background gfxterm_menu gfxterm gptsync gzio halt hashsum hdparm hello help \
	hexdump hfs hfspluscomp hfsplus http iorw iso9660 jfs jpeg keylayouts keystatus ldm legacycfg legacy_password_test \
	linux16 linux loadenv loopback lsacpi lsapm lsmmap ls lspci luks lvm lzopio macbless macho mda_text mdraid09_be \
	mdraid09 mdraid1x memdisk memrw minicmd minix2_be minix2 minix3_be minix3 minix_be minix mmap morse mpi msdospart \
	mul_test multiboot2 multiboot nativedisk net newc nilfs2 normal ntfscomp ntfs ntldr odc offsetio ohci part_acorn \
	part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool \
	password password_pbkdf2 pata pbkdf2 pbkdf2_test pcidump pci plan9 play png priority_queue probe procfs progress \
	pxechain pxe raid5rec raid6rec random read reboot regexp reiserfs relocator romfs scsi search_fs_file search_fs_uuid \
	search_label search sendkey serial setjmp setjmp_test setpci sfs shift_test signature_test sleep sleep_test \
	spem spkmodem squash4 syslinuxcfg tar terminal terminfo test_blockarg testload test testspeed tftp tga time trig tr truecrypt \
	true udf ufs1_be ufs1 ufs2 uhci usb_keyboard usb usbms usbserial_common usbserial_ftdi usbserial_pl2303 \
	usbserial_usbdebug usbtest vbe verify vga vga_text video_bochs video_cirrus video_colors video_fb videoinfo video \
	videotest_checksum videotest xfs xnu xnu_uuid xnu_uuid_test xzio zfscrypt zfsinfo zfs \
	appleldr efi_gop efi_uga efifwsetup efinet fixvideo loadbios lsefi lsefimmap lsefisystab lssal
GRUB2EFI32_CHECK_BIN_ARCH_EXCLUSIONS = \
	$(patsubst %,/usr/lib/grub/i386-efi/%.mod,$(GRUB2EFI32_MODS)) \
	$(patsubst %,/usr/lib/grub/i386-efi/%.img,$(GRUB2EFI32_IMGS))
endif


HOST_GRUB2EFI32_MODS = all_video boot chain configfile cpuid echo net ext2 extcmd fat \
	gettext gfxmenu gfxterm gzio http ntfs linux linux16 loadenv minicmd net part_gpt \
	part_msdos png progress read reiserfs search sleep terminal test tftp \
	efi_gop efi_uga efinet

HOST_GRUB2EFI32_ISOMODS = iso9660 usb

HOST_GRUB2EFI32_FONT = unicode

HOST_GRUB2EFI32_CONF_ENV = \
	$(HOST_CONFIGURE_OPTS) \
	CPP="$(HOSTCC) -E" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fno-stack-protector" \
	TARGET_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	NM="$(TARGET_NM)" \
	OBJCOPY="$(TARGET_OBJCOPY)" \
	STRIP="$(TARGET_CROSS)strip"

HOST_GRUB2EFI32_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --enable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper \
	--disable-liblzma --disable-libzfs --with-platform=efi --target=i386
HOST_GRUB2EFI32_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"

# Grub2 netdir and iso creation
ifeq ($(BR2_x86_64),y)
define HOST_GRUB2EFI32_NETDIR_INSTALLATION
	mkdir -p $(BASE_DIR)/boot/grub
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_GRUB2EFI32_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_GRUB2EFI32_MODS) $(HOST_GRUB2EFI32_ISOMODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
	mv $(BASE_DIR)/boot/grub/i386-efi/core.efi $(BASE_DIR)/boot/grub/i386-efi/core.iso
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_GRUB2EFI32_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_GRUB2EFI32_MODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
endef
HOST_GRUB2EFI32_POST_INSTALL_HOOKS += HOST_GRUB2EFI32_NETDIR_INSTALLATION
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
