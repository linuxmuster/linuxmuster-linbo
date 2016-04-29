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

# kernel
KERNEL_ARCHIVE=$(CACHEDIR)/$(shell grep " linux-" $(DEBIANDIR)/md5sums.src | awk '{ print $$2 }')
KVERS=$(shell echo $(notdir $(KERNEL_ARCHIVE)) | sed -e 's/linux-//' | sed -e 's/.tar.xz//')
BUILD32:=$(BUILDDIR)/linux32-$(KVERS)
BUILD64:=$(BUILDDIR)/linux64-$(KVERS)

# tools
URLS := http://busybox.net/downloads/busybox-1.23.2.tar.bz2 \
	http://pogostick.net/~pnh/ntpasswd/chntpw-source-140201.zip \
	$(LML_URL)/ms-sys-2.3.0.tar.gz \
	http://tuxera.com/opensource/ntfs-3g_ntfsprogs-2014.2.15.tgz \
	http://ftp.gnu.org/gnu/parted/parted-3.2.tar.xz \
	https://github.com/linuxmuster/lsaSecrets/archive/master.zip

ARCHIVES := $(addprefix $(CACHEDIR)/, $(notdir $(URLS)))

SOURCES := $(shell echo $(basename $(notdir $(ARCHIVES))) | sed -e 's/.tar//g' | sed -e 's/master/lsaSecrets-master/' -e 's/chntpw-source-/chntpw-/' )

# busybox
BB_DIR:=$(CURDIR)/$(firstword $(filter busybox-%, $(SOURCES)))
BUILDBB32=$(BUILDDIR)/build-bb32
BUILDBB64=$(BUILDDIR)/build-bb64

LINBO=$(shell find linbo -type f)
