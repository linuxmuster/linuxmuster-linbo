################################################################################
#
# linbo
#
################################################################################

LINBO_VERSION = 1.0
LINBO_DEPENDENCIES = rsync
LINBO_SITE = $(TOPDIR)/../linbo
LINBO_SITE_METHOD = local

define LINBO_INSTALL_TARGET_CMDS
	install -Dm0755 $(@D)/linbo_cmd.sh $(TARGET_DIR)/usr/bin/linbo_cmd
	install -Dm0755 $(@D)/linbo_wrapper.sh $(TARGET_DIR)/usr/bin/linbo_wrapper
	install -Dm0644 $(@D)/de-latin1-nodeadkeys.kmap $(TARGET_DIR)/usr/share/de-latin1-nodeadkeys.kmap
endef

define LINBO_INSTALL_INIT_SYSV
	install -Dm0755 $(@D)/init.sh $(TARGET_DIR)/etc/init.d/S99linbo
endef

$(eval $(generic-package))
