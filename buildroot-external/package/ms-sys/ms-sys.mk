################################################################################
#
# ms-sys
#
################################################################################

MS_SYS_VERSION = 2.4.1
MS_SYS_SOURCE = ms-sys-$(MS_SYS_VERSION).tar.gz
MS_SYS_SITE = https://sourceforge.net/projects/ms-sys/files/ms-sys%20stable/$(MS_SYS_VERSION)
MS_SYS_LICENSE = GPLv2
MS_SYS_LICENSE_FILES = COPYING

define MS_SYS_BUILD_CMDS
	CC=$(TARGET_CC) CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" $(MAKE) -C $(@D)
endef

define MS_SYS_INSTALL_TARGET_CMDS
	install -Dm0755 $(@D)/bin/ms-sys $(TARGET_DIR)/usr/bin/ms-sys
endef

$(eval $(generic-package))
