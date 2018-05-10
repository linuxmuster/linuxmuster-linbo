################################################################################
#
# linbo_gui
#
################################################################################

LINBO_GUI_VERSION = 2.0
LINBO_GUI_DEPENDENCIES = qt5base
LINBO_GUI_SITE = $(TOPDIR)/../linbo_gui-2.0
LINBO_GUI_SITE_METHOD = local
LINBO_GUI_INSTALL_STAGING = YES

define LINBO_GUI_CONFIGURE_CMDS
	cd $(@D) && $(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(QT5_QMAKE) linbo_gui.pro
endef

define LINBO_GUI_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define LINBO_GUI_INSTALL_STAGING_CMDS
	install -Dm0755 $(@D)/linbo_gui $(STAGING_DIR)/usr/bin/linbo_gui
endef

define LINBO_GUI_INSTALL_TARGET_CMDS
	install -Dm0755 $(@D)/linbo_gui $(TARGET_DIR)/usr/bin/linbo_gui
endef

$(eval $(generic-package))
