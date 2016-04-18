# only included in top level file

LML_URL=http://pkg.linuxmuster.net/linbo-build-cache

# linbo version
LVERS=$(shell head -n 1 $(CURDIR)/debian/changelog | awk -F\( '{ print $$2 }' | awk -F\) '{ print $$1 }')

# uncomment for debugging
DEBUG=true

# define CURDIR in each makefile to point to main dir
CACHEDIR=$(CURDIR)/cache
DEBIANDIR=$(CURDIR)/debian
CONFDIR=$(CURDIR)/conf
PATCHDIR=$(CURDIR)/patches

BUILDDIR=$(CURDIR)/build

SYSROOT=$(CURDIR)/sysroot
SYSROOT64=$(CURDIR)/sysroot64

# 32bit toolchain & binaries
TOOLCHAIN=$(CURDIR)/toolchain

# build arches
ARCHES=i386 amd64
