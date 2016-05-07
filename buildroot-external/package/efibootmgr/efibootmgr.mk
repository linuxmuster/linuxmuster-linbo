################################################################################
#
# efibootmgr
#
################################################################################

EFIBOOTMGR_VERSION = efibootmgr-0.12
EFIBOOTMGR_SITE = $(call github,rhinstaller,efibootmgr,$(EFIBOOTMGR_VERSION))
EFIBOOTMGR_LICENSE = GPLv2
EFIBOOTMGR_LICENSE_FILES = COPYING
EFIBOOTMGR_DEPENDENCIES = efivar

define EFIBOOTMGR_BUILD_CMDS
	$(SED) 's,-I/,-I$(STAGING_DIR)/,' $(@D)/Makefile
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) EXTRA_CFLAGS="$(TARGET_CFLAGS)" $(MAKE1) -C $(@D)
endef

define EFIBOOTMGR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/efibootmgr/efibootmgr \
		$(TARGET_DIR)/usr/bin/efibootmgr
endef

$(eval $(generic-package))
