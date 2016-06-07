################################################################################
#
# grub2bios
#
################################################################################

GRUB2BIOS_VERSION = 2.02-beta3
GRUB2BIOS_SITE = http://git.savannah.gnu.org/r/grub.git
GRUB2BIOS_SITE_METHOD = git
GRUB2BIOS_LICENSE = GPLv3
GRUB2BIOS_LICENSE_FILES = COPYING

define GRUB2BIOS_AUTOGEN
	cd $(@D) && ./autogen.sh
endef
GRUB2BIOS_PRE_CONFIGURE_HOOKS += GRUB2BIOS_AUTOGEN

GRUB2BIOS_CONF_ENV = \
	CPP="$(TARGET_CC) -E"
GRUB2BIOS_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug --disable-cache-stats --disable-boot-time --disable-grub-mkfont --enable-grub-themes --disable-grub-mount --enable-device-mapper --disable-liblzma --disable-libzfs --with-platform=pc --target=i386

define GRUB2BIOS_CLEANUP
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/*.image
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/*.module
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/kernel.exec
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/gdb_grub
	rm -fv $(TARGET_DIR)/usr/lib/grub/i386-pc/gmodule.pl
	rm -fv $(TARGET_DIR)/etc/bash_completion.d/grub
	rmdir -v $(TARGET_DIR)/etc/bash_completion.d/
	rm -rfv $(TARGET_DIR)/usr/share/grub/themes/
endef
GRUB2BIOS_POST_INSTALL_TARGET_HOOKS += GRUB2BIOS_CLEANUP

$(eval $(autotools-package))
