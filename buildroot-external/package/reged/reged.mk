################################################################################
#
# reged
#
################################################################################

REGED_VERSION = 140201
REGED_SOURCE = chntpw-source-$(REGED_VERSION).zip
REGED_SITE = http://pogostick.net/~pnh/ntpasswd
REGED_LICENSE = GPLv2
REGED_LICENSE_FILES = COPYING.txt

define REGED_EXTRACT_CMDS
	unzip -d $(@D) $(DL_DIR)/reged/$(REGED_SOURCE)
endef

define REGED_BUILD_CMDS
	cd $(@D)/chntpw-$(REGED_VERSION) && $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o reged reged.c ntreg.c edlib.c
endef

define REGED_INSTALL_TARGET_CMDS
	install -Dm0755 $(@D)/chntpw-$(REGED_VERSION)/reged $(TARGET_DIR)/usr/bin/reged
endef

$(eval $(generic-package))
