#!/usr/bin/make -f
#
# Frank Schütte
# 2016
# GPL v3
#

include common.mk

DIRS = linbo_gui

CONFIGDIRS=$(DIRS:%=config-%)
BUILDDIRS=$(DIRS:%=build-%)
CLEANDIRS=$(DIRS:%=clean-%)

# targets

all: build

configure-toolchain32:
	# setup 32bit build tool chain
	mkdir -p $(TOOLCHAIN)
	cp -f /usr/bin/ar $(TOOLCHAIN)/i386-linux-gnu-ar
	cp -f /usr/bin/strip $(TOOLCHAIN)/i386-linux-gnu-strip

$(CONFIGDIRS): configure-toolchain32
	make -C $(@:config-%=%) configure

configure: configure-stamp configure-toolchain32 $(CONFIGDIRS)
configure-stamp:
	touch configure-stamp

$(BUILDDIRS):
	make -C $(@:build-%=%) build

build: build-stamp $(BUILDDIRS)

build-stamp: configure-stamp
	touch build-stamp

$(CLEANDIRS):
	make -C $(@:clean-%=%) clean

distclean: clean

clean: $(CLEANDIRS)
	rm -f build-stamp configure-stamp $(TOOLCHAIN)/i386-linux-gnu-ar $(TOOLCHAIN)/i386-linux-gnu-strip

install: build

.PHONY: subdirs $(DIRS)
.PHONY: subdirs $(BUILDDIRS)
.PHONY: subdirs $(CONFIGDIRS)
.PHONY: subdirs $(CLEANDIRS)
.PHONY: build clean install configure
