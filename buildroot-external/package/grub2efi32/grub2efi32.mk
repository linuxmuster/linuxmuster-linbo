################################################################################
#
# grub2efi32
#
################################################################################

GRUB2EFI32_VERSION = 2.02-beta3
GRUB2EFI32_SITE = http://git.savannah.gnu.org/r/grub.git
GRUB2EFI32_SITE_METHOD = git
GRUB2EFI32_LICENSE = GPLv3
GRUB2EFI32_LICENSE_FILES = COPYING

define GRUB2EFI32_AUTOGEN
	cd $(@D) && ./autogen.sh
endef
GRUB2EFI32_PRE_CONFIGURE_HOOKS += GRUB2EFI32_AUTOGEN

GRUB2EFI32_CONF_ENV = \
	CPP="$(TARGET_CC) -E"
GRUB2EFI32_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug --disable-cache-stats --disable-boot-time --disable-grub-mkfont --disable-grub-themes --disable-grub-mount --enable-device-mapper --disable-liblzma --disable-libzfs --with-platform=efi  --target=i386

define GRUB2EFI32_CLEANUP
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/*.image
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/*.module
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/kernel.exec
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/gdb_grub
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-efi/gmodule.pl
endef
GRUB2EFI32_POST_INSTALL_TARGET_HOOKS += GRUB2EFI32_CLEANUP

$(eval $(autotools-package))
