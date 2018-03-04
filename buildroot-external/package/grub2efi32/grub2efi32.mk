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

GRUB2EFI32_MODS = all_video boot chain configfile cpuid echo net ext2 extcmd fat \
	gettext gfxmenu gfxterm gzio http ntfs linux linux16 loadenv minicmd net part_gpt \
	part_msdos png progress read reiserfs search sleep terminal test tftp \
	efi_gop efi_uga efinet

GRUB2EFI32_ISOMODS = iso9660 usb

GRUB2EFI32_FONT = unicode

GRUB2EFI32_CONF_ENV = \
	$(HOST_CONFIGURE_OPTS) \
	CPP="$(HOSTCC) -E" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fno-stack-protector" \
	TARGET_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	NM="$(TARGET_NM)" \
	OBJCOPY="$(TARGET_OBJCOPY)" \
	STRIP="$(TARGET_CROSS)strip"

GRUB2EFI32_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --enable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper \
	--disable-liblzma --disable-libzfs --with-platform=efi --target=i386
GRUB2EFI32_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"

GRUB2EFI32_INSTALL_TARGET_OPTS = DESTDIR=$(HOST_DIR) install

# Grub2 netdir and iso creation
ifeq ($(BR2_x86_64),y)
define GRUB2EFI32_NETDIR_INSTALLATION
	mkdir -p $(BASE_DIR)/boot/grub
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(GRUB2EFI32_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(GRUB2EFI32_MODS) $(GRUB2EFI32_ISOMODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
	mv $(BASE_DIR)/boot/grub/i386-efi/core.efi $(BASE_DIR)/boot/grub/i386-efi/core.iso
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(GRUB2EFI32_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(GRUB2EFI32_MODS)" \
		-d $(HOST_DIR)/lib/grub/i386-efi
endef
GRUB2EFI32_POST_INSTALL_TARGET_HOOKS += GRUB2EFI32_NETDIR_INSTALLATION
endif

ifeq ($(BR2_i386),y)
GRUB2EFI32_CHECK_BIN_ARCH_EXCLUSIONS = \
/usr/bin/grub-editenv \
/usr/bin/grub-file \
/usr/bin/grub-fstest \
/usr/bin/grub-glue-efi \
/usr/bin/grub-menulst2cfg \
/usr/bin/grub-mkfont \
/usr/bin/grub-mkimage \
/usr/bin/grub-mklayout \
/usr/bin/grub-mknetdir \
/usr/bin/grub-mkpasswd-pbkdf2 \
/usr/bin/grub-mkrelpath \
/usr/bin/grub-mkrescue \
/usr/bin/grub-mkstandalone \
/usr/bin/grub-render-label \
/usr/bin/grub-script-check \
/usr/bin/grub-syslinux2cfg \
/usr/sbin/grub-bios-setup \
/usr/sbin/grub-install \
/usr/sbin/grub-macbless \
/usr/sbin/grub-ofpathname \
/usr/sbin/grub-probe \
/usr/sbin/grub-sparc64-setup
endif

ifeq ($(BR2_x86_64),y)
GRUB2EFI32_CHECK_BIN_ARCH_EXCLUSIONS = \
/usr/lib/grub/i386-efi/acpi.mod \
/usr/lib/grub/i386-efi/pxeboot.img \
/usr/lib/grub/i386-efi/tar.mod \
/usr/lib/grub/i386-efi/partmap.lst \
/usr/lib/grub/i386-efi/minix3.mod \
/usr/lib/grub/i386-efi/test.mod \
/usr/lib/grub/i386-efi/freedos.mod \
/usr/lib/grub/i386-efi/xnu_uuid.mod \
/usr/lib/grub/i386-efi/zfscrypt.mod \
/usr/lib/grub/i386-efi/part_msdos.mod \
/usr/lib/grub/i386-efi/trig.mod \
/usr/lib/grub/i386-efi/tr.mod \
/usr/lib/grub/i386-efi/cdboot.img \
/usr/lib/grub/i386-efi/gcry_dsa.mod \
/usr/lib/grub/i386-efi/bfs.mod \
/usr/lib/grub/i386-efi/mdraid09_be.mod \
/usr/lib/grub/i386-efi/gptsync.mod \
/usr/lib/grub/i386-efi/loopback.mod \
/usr/lib/grub/i386-efi/ext2.mod \
/usr/lib/grub/i386-efi/test_blockarg.mod \
/usr/lib/grub/i386-efi/keylayouts.mod \
/usr/lib/grub/i386-efi/gfxterm_background.mod \
/usr/lib/grub/i386-efi/gcry_rmd160.mod \
/usr/lib/grub/i386-efi/font.mod \
/usr/lib/grub/i386-efi/gcry_sha256.mod \
/usr/lib/grub/i386-efi/mda_text.mod \
/usr/lib/grub/i386-efi/reiserfs.mod \
/usr/lib/grub/i386-efi/cmdline_cat_test.mod \
/usr/lib/grub/i386-efi/syslinuxcfg.mod \
/usr/lib/grub/i386-efi/affs.mod \
/usr/lib/grub/i386-efi/verify.mod \
/usr/lib/grub/i386-efi/raid5rec.mod \
/usr/lib/grub/i386-efi/gdb.mod \
/usr/lib/grub/i386-efi/halt.mod \
/usr/lib/grub/i386-efi/png.mod \
/usr/lib/grub/i386-efi/exfctest.mod \
/usr/lib/grub/i386-efi/bswap_test.mod \
/usr/lib/grub/i386-efi/boot.mod \
/usr/lib/grub/i386-efi/minix2.mod \
/usr/lib/grub/i386-efi/linux.mod \
/usr/lib/grub/i386-efi/vbe.mod \
/usr/lib/grub/i386-efi/div_test.mod \
/usr/lib/grub/i386-efi/ohci.mod \
/usr/lib/grub/i386-efi/mdraid1x.mod \
/usr/lib/grub/i386-efi/hfsplus.mod \
/usr/lib/grub/i386-efi/crypto.mod \
/usr/lib/grub/i386-efi/gcry_blowfish.mod \
/usr/lib/grub/i386-efi/ntldr.mod \
/usr/lib/grub/i386-efi/search_fs_uuid.mod \
/usr/lib/grub/i386-efi/truecrypt.mod \
/usr/lib/grub/i386-efi/cmostest.mod \
/usr/lib/grub/i386-efi/tga.mod \
/usr/lib/grub/i386-efi/part_dfly.mod \
/usr/lib/grub/i386-efi/bsd.mod \
/usr/lib/grub/i386-efi/gcry_sha1.mod \
/usr/lib/grub/i386-efi/gfxterm.mod \
/usr/lib/grub/i386-efi/gfxmenu.mod \
/usr/lib/grub/i386-efi/net.mod \
/usr/lib/grub/i386-efi/aout.mod \
/usr/lib/grub/i386-efi/videotest.mod \
/usr/lib/grub/i386-efi/squash4.mod \
/usr/lib/grub/i386-efi/echo.mod \
/usr/lib/grub/i386-efi/part_bsd.mod \
/usr/lib/grub/i386-efi/cpio_be.mod \
/usr/lib/grub/i386-efi/gcry_camellia.mod \
/usr/lib/grub/i386-efi/usb_keyboard.mod \
/usr/lib/grub/i386-efi/setjmp.mod \
/usr/lib/grub/i386-efi/usbserial_pl2303.mod \
/usr/lib/grub/i386-efi/cbfs.mod \
/usr/lib/grub/i386-efi/keystatus.mod \
/usr/lib/grub/i386-efi/pata.mod \
/usr/lib/grub/i386-efi/reboot.mod \
/usr/lib/grub/i386-efi/eval.mod \
/usr/lib/grub/i386-efi/plan9.mod \
/usr/lib/grub/i386-efi/linux16.mod \
/usr/lib/grub/i386-efi/memdisk.mod \
/usr/lib/grub/i386-efi/gcry_crc.mod \
/usr/lib/grub/i386-efi/chain.mod \
/usr/lib/grub/i386-efi/bufio.mod \
/usr/lib/grub/i386-efi/minix3_be.mod \
/usr/lib/grub/i386-efi/lsmmap.mod \
/usr/lib/grub/i386-efi/xnu.mod \
/usr/lib/grub/i386-efi/luks.mod \
/usr/lib/grub/i386-efi/cryptodisk.mod \
/usr/lib/grub/i386-efi/gcry_rfc2268.mod \
/usr/lib/grub/i386-efi/zfsinfo.mod \
/usr/lib/grub/i386-efi/memrw.mod \
/usr/lib/grub/i386-efi/msdospart.mod \
/usr/lib/grub/i386-efi/uhci.mod \
/usr/lib/grub/i386-efi/archelp.mod \
/usr/lib/grub/i386-efi/legacy_password_test.mod \
/usr/lib/grub/i386-efi/terminal.mod \
/usr/lib/grub/i386-efi/hello.mod \
/usr/lib/grub/i386-efi/ntfs.mod \
/usr/lib/grub/i386-efi/hfs.mod \
/usr/lib/grub/i386-efi/pbkdf2.mod \
/usr/lib/grub/i386-efi/ahci.mod \
/usr/lib/grub/i386-efi/gcry_sha512.mod \
/usr/lib/grub/i386-efi/sfs.mod \
/usr/lib/grub/i386-efi/procfs.mod \
/usr/lib/grub/i386-efi/video_bochs.mod \
/usr/lib/grub/i386-efi/play.mod \
/usr/lib/grub/i386-efi/hdparm.mod \
/usr/lib/grub/i386-efi/offsetio.mod \
/usr/lib/grub/i386-efi/password_pbkdf2.mod \
/usr/lib/grub/i386-efi/morse.mod \
/usr/lib/grub/i386-efi/fat.mod \
/usr/lib/grub/i386-efi/usb.mod \
/usr/lib/grub/i386-efi/lvm.mod \
/usr/lib/grub/i386-efi/normal.mod \
/usr/lib/grub/i386-efi/gcry_twofish.mod \
/usr/lib/grub/i386-efi/cs5536.mod \
/usr/lib/grub/i386-efi/read.mod \
/usr/lib/grub/i386-efi/biosdisk.mod \
/usr/lib/grub/i386-efi/romfs.mod \
/usr/lib/grub/i386-efi/xfs.mod \
/usr/lib/grub/i386-efi/search.mod \
/usr/lib/grub/i386-efi/true.mod \
/usr/lib/grub/i386-efi/adler32.mod \
/usr/lib/grub/i386-efi/fshelp.mod \
/usr/lib/grub/i386-efi/videotest_checksum.mod \
/usr/lib/grub/i386-efi/lsacpi.mod \
/usr/lib/grub/i386-efi/macbless.mod \
/usr/lib/grub/i386-efi/hfspluscomp.mod \
/usr/lib/grub/i386-efi/odc.mod \
/usr/lib/grub/i386-efi/vga.mod \
/usr/lib/grub/i386-efi/backtrace.mod \
/usr/lib/grub/i386-efi/mdraid09.mod \
/usr/lib/grub/i386-efi/search_fs_file.mod \
/usr/lib/grub/i386-efi/gcry_idea.mod \
/usr/lib/grub/i386-efi/help.mod \
/usr/lib/grub/i386-efi/datehook.mod \
/usr/lib/grub/i386-efi/dm_nv.mod \
/usr/lib/grub/i386-efi/newc.mod \
/usr/lib/grub/i386-efi/mpi.mod \
/usr/lib/grub/i386-efi/cmosdump.mod \
/usr/lib/grub/i386-efi/pcidump.mod \
/usr/lib/grub/i386-efi/scsi.mod \
/usr/lib/grub/i386-efi/elf.mod \
/usr/lib/grub/i386-efi/nativedisk.mod \
/usr/lib/grub/i386-efi/terminfo.mod \
/usr/lib/grub/i386-efi/multiboot.mod \
/usr/lib/grub/i386-efi/ctz_test.mod \
/usr/lib/grub/i386-efi/part_plan.mod \
/usr/lib/grub/i386-efi/bitmap_scale.mod \
/usr/lib/grub/i386-efi/ufs1.mod \
/usr/lib/grub/i386-efi/part_dvh.mod \
/usr/lib/grub/i386-efi/gcry_md5.mod \
/usr/lib/grub/i386-efi/configfile.mod \
/usr/lib/grub/i386-efi/zfs.mod \
/usr/lib/grub/i386-efi/spkmodem.mod \
/usr/lib/grub/i386-efi/pxechain.mod \
/usr/lib/grub/i386-efi/usbtest.mod \
/usr/lib/grub/i386-efi/ufs2.mod \
/usr/lib/grub/i386-efi/macho.mod \
/usr/lib/grub/i386-efi/gcry_whirlpool.mod \
/usr/lib/grub/i386-efi/minix.mod \
/usr/lib/grub/i386-efi/part_acorn.mod \
/usr/lib/grub/i386-efi/jpeg.mod \
/usr/lib/grub/i386-efi/signature_test.mod \
/usr/lib/grub/i386-efi/minix2_be.mod \
/usr/lib/grub/i386-efi/vga_text.mod \
/usr/lib/grub/i386-efi/at_keyboard.mod \
/usr/lib/grub/i386-efi/parttool.mod \
/usr/lib/grub/i386-efi/gcry_md4.mod \
/usr/lib/grub/i386-efi/videoinfo.mod \
/usr/lib/grub/i386-efi/video_fb.mod \
/usr/lib/grub/i386-efi/cmp_test.mod \
/usr/lib/grub/i386-efi/priority_queue.mod \
/usr/lib/grub/i386-efi/kernel.img \
/usr/lib/grub/i386-efi/testload.mod \
/usr/lib/grub/i386-efi/hexdump.mod \
/usr/lib/grub/i386-efi/pbkdf2_test.mod \
/usr/lib/grub/i386-efi/part_sunpc.mod \
/usr/lib/grub/i386-efi/iorw.mod \
/usr/lib/grub/i386-efi/pci.mod \
/usr/lib/grub/i386-efi/cat.mod \
/usr/lib/grub/i386-efi/sleep_test.mod \
/usr/lib/grub/i386-efi/pxe.mod \
/usr/lib/grub/i386-efi/gzio.mod \
/usr/lib/grub/i386-efi/all_video.mod \
/usr/lib/grub/i386-efi/lsapm.mod \
/usr/lib/grub/i386-efi/serial.mod \
/usr/lib/grub/i386-efi/lzopio.mod \
/usr/lib/grub/i386-efi/date.mod \
/usr/lib/grub/i386-efi/regexp.mod \
/usr/lib/grub/i386-efi/diskfilter.mod \
/usr/lib/grub/i386-efi/usbserial_usbdebug.mod \
/usr/lib/grub/i386-efi/ufs1_be.mod \
/usr/lib/grub/i386-efi/ntfscomp.mod \
/usr/lib/grub/i386-efi/mul_test.mod \
/usr/lib/grub/i386-efi/testspeed.mod \
/usr/lib/grub/i386-efi/relocator.mod \
/usr/lib/grub/i386-efi/progress.mod \
/usr/lib/grub/i386-efi/xzio.mod \
/usr/lib/grub/i386-efi/multiboot2.mod \
/usr/lib/grub/i386-efi/ls.mod \
/usr/lib/grub/i386-efi/part_sun.mod \
/usr/lib/grub/i386-efi/gcry_serpent.mod \
/usr/lib/grub/i386-efi/time.mod \
/usr/lib/grub/i386-efi/setpci.mod \
/usr/lib/grub/i386-efi/raid6rec.mod \
/usr/lib/grub/i386-efi/mmap.mod \
/usr/lib/grub/i386-efi/sendkey.mod \
/usr/lib/grub/i386-efi/video.mod \
/usr/lib/grub/i386-efi/ata.mod \
/usr/lib/grub/i386-efi/cmp.mod \
/usr/lib/grub/i386-efi/gcry_seed.mod \
/usr/lib/grub/i386-efi/minix_be.mod \
/usr/lib/grub/i386-efi/legacycfg.mod \
/usr/lib/grub/i386-efi/exfat.mod \
/usr/lib/grub/i386-efi/btrfs.mod \
/usr/lib/grub/i386-efi/gcry_des.mod \
/usr/lib/grub/i386-efi/div.mod \
/usr/lib/grub/i386-efi/cpuid.mod \
/usr/lib/grub/i386-efi/gcry_tiger.mod \
/usr/lib/grub/i386-efi/gcry_rijndael.mod \
/usr/lib/grub/i386-efi/password.mod \
/usr/lib/grub/i386-efi/crc64.mod \
/usr/lib/grub/i386-efi/lspci.mod \
/usr/lib/grub/i386-efi/xnu_uuid_test.mod \
/usr/lib/grub/i386-efi/setjmp_test.mod \
/usr/lib/grub/i386-efi/datetime.mod \
/usr/lib/grub/i386-efi/http.mod \
/usr/lib/grub/i386-efi/part_apple.mod \
/usr/lib/grub/i386-efi/gcry_arcfour.mod \
/usr/lib/grub/i386-efi/hashsum.mod \
/usr/lib/grub/i386-efi/gfxterm_menu.mod \
/usr/lib/grub/i386-efi/video_cirrus.mod \
/usr/lib/grub/i386-efi/ldm.mod \
/usr/lib/grub/i386-efi/cbtime.mod \
/usr/lib/grub/i386-efi/minicmd.mod \
/usr/lib/grub/i386-efi/extcmd.mod \
/usr/lib/grub/i386-efi/bitmap.mod \
/usr/lib/grub/i386-efi/ehci.mod \
/usr/lib/grub/i386-efi/cpio.mod \
/usr/lib/grub/i386-efi/usbserial_common.mod \
/usr/lib/grub/i386-efi/gcry_rsa.mod \
/usr/lib/grub/i386-efi/probe.mod \
/usr/lib/grub/i386-efi/gcry_cast5.mod \
/usr/lib/grub/i386-efi/part_amiga.mod \
/usr/lib/grub/i386-efi/geli.mod \
/usr/lib/grub/i386-efi/udf.mod \
/usr/lib/grub/i386-efi/iso9660.mod \
/usr/lib/grub/i386-efi/cbmemc.mod \
/usr/lib/grub/i386-efi/cbtable.mod \
/usr/lib/grub/i386-efi/functional_test.mod \
/usr/lib/grub/i386-efi/tftp.mod \
/usr/lib/grub/i386-efi/gettext.mod \
/usr/lib/grub/i386-efi/video_colors.mod \
/usr/lib/grub/i386-efi/usbms.mod \
/usr/lib/grub/i386-efi/loadenv.mod \
/usr/lib/grub/i386-efi/disk.mod \
/usr/lib/grub/i386-efi/cbls.mod \
/usr/lib/grub/i386-efi/drivemap.mod \
/usr/lib/grub/i386-efi/random.mod \
/usr/lib/grub/i386-efi/efiemu.mod \
/usr/lib/grub/i386-efi/jfs.mod \
/usr/lib/grub/i386-efi/shift_test.mod \
/usr/lib/grub/i386-efi/file.mod \
/usr/lib/grub/i386-efi/blocklist.mod \
/usr/lib/grub/i386-efi/usbserial_ftdi.mod \
/usr/lib/grub/i386-efi/afs.mod \
/usr/lib/grub/i386-efi/sleep.mod \
/usr/lib/grub/i386-efi/search_label.mod \
/usr/lib/grub/i386-efi/part_gpt.mod \
/usr/lib/grub/i386-efi/nilfs2.mod \
/usr/lib/grub/i386-efi/efifwsetup.mod \
/usr/lib/grub/i386-efi/lsefi.mod \
/usr/lib/grub/i386-efi/loadbios.mod \
/usr/lib/grub/i386-efi/lssal.mod \
/usr/lib/grub/i386-efi/fixvideo.mod \
/usr/lib/grub/i386-efi/appleldr.mod \
/usr/lib/grub/i386-efi/lsefimmap.mod \
/usr/lib/grub/i386-efi/efinet.mod \
/usr/lib/grub/i386-efi/lsefisystab.mod \
/usr/lib/grub/i386-efi/efi_gop.mod \
/usr/lib/grub/i386-efi/efi_uga.mod
endif

$(eval $(autotools-package))
