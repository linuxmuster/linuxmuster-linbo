################################################################################
#
# cloop
#
################################################################################

CLOOP_VERSION = 5.1
CLOOP_SOURCE = Cloop-$(CLOOP_VERSION).zip
CLOOP_SITE = http://knopper.net/linuxmuster
CLOOP_LICENSE = GPLv2
CLOOP_LICENSE_FILES = debian/copyright
CLOOP_SUBDIR = advancecomp-1.15
CLOOP_MAKE_OPTS = advfs

define CLOOP_EXTRACT_CMDS
	unzip $(CLOOP_DL_DIR)/$(CLOOP_SOURCE) -d $(@D)
	mv $(@D)/Cloop/* $(@D)
	rmdir $(@D)/Cloop
endef

define CLOOP_BUILD_UTILS
	$(TARGET_CC) $(TARGET_CFLAGS) -D_GNU_SOURCE $(TARGET_LDFLAGS) -o $(@D)/extract_compressed_fs $(@D)/extract_compressed_fs.c -lz
endef
CLOOP_POST_BUILD_HOOKS += CLOOP_BUILD_UTILS

define CLOOP_INSTALL_TARGET_CMDS
	install -Dm0755 $(@D)/advancecomp-1.15/advfs $(TARGET_DIR)/usr/bin/create_compressed_fs
	install -Dm0755 $(@D)/extract_compressed_fs $(TARGET_DIR)/usr/bin/extract_compressed_fs
endef

$(eval $(kernel-module))
# error because HOST_... is defined
HOST_CLOOP_KCONFIG_VAR =
$(eval $(autotools-package))
