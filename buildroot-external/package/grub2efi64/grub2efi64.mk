################################################################################
#
# grub2efi64
#
################################################################################

GRUB2EFI64_VERSION = 2.02
GRUB2EFI64_SOURCE = grub-$(GRUB2EFI64_VERSION).tar.gz
GRUB2EFI64_SITE = ftp://ftp.gnu.org/gnu/grub
GRUB2EFI64_LICENSE = GPLv3
GRUB2EFI64_LICENSE_FILES = COPYING

GRUB2EFI64_CONF_ENV = \
	$(HOST_CONFIGURE_OPTS) \
	CPP="$(HOSTCC) -E" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fno-stack-protector" \
	TARGET_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	NM="$(TARGET_NM)" \
	OBJCOPY="$(TARGET_OBJCOPY)" \
	STRIP="$(TARGET_CROSS)strip"

GRUB2EFI64_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --enable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper \
	--disable-liblzma --disable-libzfs --with-platform=efi --target=x86_64
GRUB2EFI64_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"

define GRUB2EFI64_CLEANUP
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/*.image
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/*.module
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/kernel.exec
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/gdb_grub
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/gmodule.pl
	rm -fv $(TARGET_DIR)/etc/bash_completion.d/grub
	rmdir -v $(TARGET_DIR)/etc/bash_completion.d/
endef
GRUB2EFI64_POST_INSTALL_TARGET_HOOKS += GRUB2EFI64_CLEANUP

$(eval $(autotools-package))
