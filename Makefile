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

# sub makefiles
SUBS = kernel sysroot

CONFIGSUBS=$(SUBS:%=config-%)
BUILDSUBS=$(SUBS:%=build-%)
CLEANSUBS=$(SUBS:%=clean-%)

# targets

all: build

configure-toolchain32:
	# setup 32bit build tool chain
	mkdir -p $(TOOLCHAIN)
	cp -f /usr/bin/ar $(TOOLCHAIN)/i386-linux-gnu-ar
	cp -f /usr/bin/strip $(TOOLCHAIN)/i386-linux-gnu-strip

$(CONFIGDIRS): configure-toolchain32
	make -C $(@:config-%=%) configure

$(CONFIGSUBS): configure-toolchain32
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

distclean: clean

clean: $(CLEANSUBS) $(CLEANDIRS)
	rm -f build-stamp configure-stamp $(TOOLCHAIN)/i386-linux-gnu-ar $(TOOLCHAIN)/i386-linux-gnu-strip

install: build

.PHONY: subdirs $(DIRS)
.PHONY: subdirs $(BUILDDIRS)
.PHONY: subdirs $(CONFIGDIRS)
.PHONY: subdirs $(CLEANDIRS)
.PHONY: $(CONFIGSUBS) $(BUILDSUBS) $(CLEANSUBS)
.PHONY: build clean install configure
