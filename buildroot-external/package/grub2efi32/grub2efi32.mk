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
GRUB2EFI32_CHECK_BIN_ARCH_EXCLUSIONS = \
	$(patsubst $(TARGET_DIR)%,%,$(wildcard $(TARGET_DIR)/usr/lib/grub/i386-efi/*.mod)) \
	$(patsubst $(TARGET_DIR)%,%,$(wildcard $(TARGET_DIR)/usr/lib/grub/i386-efi/*.img))
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
HOST_GRUB2EFI32_POST_INSTALL_HOOKS += GRUB2EFI32_NETDIR_INSTALLATION
endif

ifeq ($(BR2_i386),y)
HOST_GRUB2EFI32_CHECK_BIN_ARCH_EXCLUSIONS = \
	$(patsubst $(TARGET_DIR)%,%,$(wildcard $(TARGET_DIR)/usr/bin/grub-*)) \
	$(patsubst $(TARGET_DIR)%,%,$(wildcard $(TARGET_DIR)/usr/sbin/grub-*))
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
