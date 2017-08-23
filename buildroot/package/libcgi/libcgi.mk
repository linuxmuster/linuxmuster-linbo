################################################################################
#
# libcgi
#
################################################################################

LIBCGI_VERSION = 1.0
LIBCGI_SITE = http://downloads.sourceforge.net/project/libcgi/libcgi/$(LIBCGI_VERSION)
LIBCGI_INSTALL_STAGING = YES
# use cross CC/AR rather than host
LIBCGI_MAKE_ENV = CC="$(TARGET_CC) $(TARGET_CFLAGS)" AR="$(TARGET_AR)" \
	$(if $(BR2_STATIC_LIBS),STATIC=1)
LIBCGI_LICENSE = LGPL-2.1+

$(eval $(autotools-package))