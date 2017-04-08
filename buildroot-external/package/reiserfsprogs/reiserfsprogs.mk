################################################################################
#
# reiserfsprogs
#
################################################################################

REISERFSPROGS_VERSION = 3.6.24
REISERFSPROGS_SOURCE = reiserfsprogs-$(REISERFSPROGS_VERSION).tar.xz
REISERFSPROGS_SITE = https://www.kernel.org/pub/linux/kernel/people/jeffm/reiserfsprogs/v$(REISERFSPROGS_VERSION)
REISERFSPROGS_LICENSE = GPLv2 with modifications
REISERFSPROGS_LICENSE_FILES = COPYING README
REISERFSPROGS_DEPENDENCIES = util-linux
REISERFSPROGS_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -std=gnu89"

define REISERFSPROGS_AUTORECONF
	cd $(@D) && autoreconf -fvi
endef
REISERFSPROGS_PRE_CONFIGURE_HOOKS += REISERFSPROGS_AUTORECONF

define REISERFSPROGS_CLEANUP
	rm -fv $(TARGET_DIR)/usr/sbin/debugfs.reiserfs
	rm -fv $(TARGET_DIR)/usr/sbin/fsck.reiserfs
	rm -fv $(TARGET_DIR)/usr/share/man/man8/fsck.reiserfs.8
	rm -fv $(TARGET_DIR)/usr/sbin/mkfs.reiserfs
	rm -fv $(TARGET_DIR)/usr/share/man/man8/debugfs.reiserfs.8
	rm -fv $(TARGET_DIR)/usr/sbin/tunefs.reiserfs
	rm -fv $(TARGET_DIR)/usr/share/man/man8/mkfs.reiserfs.8
endef
REISERFSPROGS_PRE_INSTALL_TARGET_HOOKS += REISERFSPROGS_CLEANUP

$(eval $(autotools-package))
