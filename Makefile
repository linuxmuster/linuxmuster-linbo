#!/usr/bin/make -f
#
# Dieses Makefile ruft die anderen Makefiles auf und sammelt schließlich alle
# Dateien aus den sysroot-Verzeichnissen ein.
#
# Frank Schütte
# 2016
# GPL v3
#

include common.mk

CURDIR=$(shell pwd)

DIRS = linbo_gui

CONFIGDIRS=$(DIRS:%=config-%)
BUILDDIRS=$(DIRS:%=build-%)
CLEANDIRS=$(DIRS:%=clean-%)
DISTCLEANDIRS=$(DIRS:%=distclean-%)
INSTALLDIRS=$(DIRS:%=install-%)

# sub makefiles
SUBS = sysroot tools

CONFIGSUBS=$(SUBS:%=config-%)
BUILDSUBS=$(SUBS:%=build-%)
CLEANSUBS=$(SUBS:%=clean-%)
DISTCLEANSUBS=$(SUBS:%=distclean-%)
INSTALLSUBS=$(SUBS:%=install-%)

# targets

all: build

install-kernel:
	make -f Makefile.kernel install

configure-toolchain32:
	# setup 32bit build tool chain
	mkdir -p $(TOOLCHAIN)
	cp -f /usr/bin/ar $(TOOLCHAIN)/i386-linux-gnu-ar
	cp -f /usr/bin/strip $(TOOLCHAIN)/i386-linux-gnu-strip

$(CONFIGDIRS): configure-toolchain32
	make -C $(@:config-%=%) configure

$(CONFIGSUBS): configure-toolchain32 install-kernel
	make -f Makefile.$(@:config-%=%) configure

configure: configure-stamp configure-toolchain32 $(CONFIGSUBS) $(CONFIGDIRS)
configure-stamp:
	touch configure-stamp

$(BUILDDIRS):
	make -C $(@:build-%=%) build

$(BUILDSUBS):
	make -f Makefile.$(@:build-%=%) build

build: build-stamp $(BUILDSUBS) $(BUILDDIRS)

build-stamp: configure-stamp
	touch build-stamp

$(CLEANDIRS):
	make -C $(@:clean-%=%) clean

$(CLEANSUBS):
	make -f Makefile.$(@:clean-%=%) clean
	make -f Makefile.kernel clean

$(DISTCLEANDIRS):
	make -C $(@:distclean-%=%) distclean

$(DISTCLEANSUBS):
	make -f Makefile.$(@:distclean-%=%) distclean
	make -f Makefile.kernel distclean

distclean: clean $(DISTCLEANSUBS) $(DISTCLEANDIRS)

clean: $(CLEANSUBS) $(CLEANDIRS)
	rm -f build-stamp configure-stamp $(TOOLCHAIN)/i386-linux-gnu-ar $(TOOLCHAIN)/i386-linux-gnu-strip

$(INSTALLDIRS):
	make -C $(@:install-%=%) install

$(INSTALLSUBS):
	make -f Makefile.$(@:install-%=%) install

install: $(INSTALLSUBS) $(INSTALLDIRS)

.PHONY: subdirs $(DIRS)
.PHONY: subdirs $(BUILDDIRS)
.PHONY: subdirs $(CONFIGDIRS)
.PHONY: subdirs $(CLEANDIRS)
.PHONY: $(CONFIGSUBS) $(BUILDSUBS) $(CLEANSUBS) $(INSTALLSUBS)
.PHONY: build clean install install-kernel configure
