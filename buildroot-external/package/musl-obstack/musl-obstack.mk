################################################################################
#
# musl-obstack
#
################################################################################

MUSL_OBSTACK_VERSION = 1.0
MUSL_OBSTACK_SOURCE = v$(MUSL_OBSTACK_VERSION).tar.gz
MUSL_OBSTACK_SITE = https://github.com/pullmoll/musl-obstack/archive
MUSL_OBSTACK_LICENSE = GPLv2
MUSL_OBSTACK_LICENSE_FILES = COPYING
MUSL_OBSTACK_INSTALL_STAGING = YES

define MUSL_OBSTACK_BOOTSTRAP
	cd $(@D) && ./bootstrap.sh
endef
MUSL_OBSTACK_PRE_CONFIGURE_HOOKS += MUSL_OBSTACK_BOOTSTRAP

$(eval $(autotools-package))
