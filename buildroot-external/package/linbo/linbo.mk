################################################################################
#
# linbo
#
################################################################################

LINBO_VERSION = 1.1
LINBO_DEPENDENCIES = rsync
LINBO_SITE = $(TOPDIR)/../linbo
LINBO_SITE_METHOD = local

define LINBO_INSTALL_TARGET_CMDS
	install -Dm0755 $(@D)/linbo_cmd.sh $(TARGET_DIR)/usr/bin/linbo_cmd
	install -Dm0755 $(@D)/linbo_wrapper.sh $(TARGET_DIR)/usr/bin/linbo_wrapper
	install -Dm0755 $(@D)/patch_registry.sh $(TARGET_DIR)/usr/bin/patch_registry
	install -Dm0755 $(@D)/linuxmuster-win/install-start-tasks.sh $(TARGET_DIR)/linuxmuster-win/install-start-tasks.sh
	install -Dm0644 $(@D)/linuxmuster-win/start-tasks.reg.tpl $(TARGET_DIR)/linuxmuster-win/start-tasks.reg.tpl
	install -Dm0644 $(@D)/etc/newdev-patch.bvi $(TARGET_DIR)/etc/newdev-patch.bvi
	install -Dm0755 $(@D)/usr/share/udhcpc/default.script $(TARGET_DIR)/usr/share/udhcpc/default.script.d/linbo.sh
	install -Dm0644 $(@D)/etc/linbo-version $(TARGET_DIR)/etc/linbo-version
	install -Dm0644 $(@D)/de-latin1-nodeadkeys.kmap $(TARGET_DIR)/usr/share/de-latin1-nodeadkeys.kmap
	ln -fs mkfs.fat $(TARGET_DIR)/usr/sbin/mkdosfs
	install -d $(TARGET_DIR)/cache
endef

define LINBO_INSTALL_INIT_SYSV
	install -Dm0755 $(@D)/init.sh $(TARGET_DIR)/etc/init.d/S99linbo
endef

$(eval $(generic-package))
