################################################################################
#
# cloop
#
################################################################################

CLOOP_VERSION = 3.14.1.2
CLOOP_SOURCE = cloop_$(CLOOP_VERSION).tar.xz
CLOOP_SITE = http://ftp.de.debian.org/debian/pool/main/c/cloop
CLOOP_LICENSE = GPLv2
CLOOP_LICENSE_FILES = debian/copyright
CLOOP_SUBDIR = advancecomp-1.15
CLOOP_MAKE_OPTS = advfs

define CLOOP_BUILD_UTILS
	$(TARGET_CC) $(TARGET_CFLAGS) -D_GNU_SOURCE $(TARGET_LDFLAGS) -o $(@D)/extract_compressed_fs $(@D)/extract_compressed_fs.c -lz
endef
CLOOP_POST_BUILD_HOOKS += CLOOP_BUILD_UTILS

define CLOOP_INSTALL_TARGET_CMDS
	install -Dm0755 $(@D)/advancecomp-1.15/advfs $(TARGET_DIR)/usr/bin/create_compressed_fs
	install -Dm0755 $(@D)/extract_compressed_fs $(TARGET_DIR)/usr/bin/extract_compressed_fs
endef

$(eval $(kernel-module))
$(eval $(autotools-package))
