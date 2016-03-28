#!/usr/bin/make -f
#
# make linbo gui
#
# Frank Schütte
# 2016

include ../common.mk

ifdef $(DEBUG)
    QT_DEBUG=-debug
else
    QT_DEBUG=
endif

# qt
QT_ARCHIVE_NAME=$(shell grep qt- $(DEBIANDIR)/md5sums.src | awk '{ print $$2 }')
QT_ARCHIVE=$(CACHEDIR)/$(QT_ARCHIVE_NAME)
QT_VERS=$(shell echo $(QT_ARCHIVE_NAME) | sed -e 's/qt-everywhere-opensource-src-//' -e 's/.7z//')
QT_URL=http://download.qt-project.org/official_releases/qt/5.5/$(QT_VERS)/single
QT_SRC=$(CURDIR)/$(shell echo $(QT_ARCHIVE_NAME) | sed -e 's/.7z//')
QT_BUILD32=$(BUILDDIR)/build-qt32
QT_BUILD32OPTS=-xplatform linux-g++-32 -device-option CROSS_COMPILE=i386-linux-gnu-
QT_BUILD64=$(BUILDDIR)/build-qt64
QT_BUILD64OPTS=-sysroot $(SYSROOT64) 
QT_OPTS=-debug -qpa linuxfb -linuxfb -static -opensource -confirm-license -nomake examples \
	-verbose -no-dbus -no-largefile -no-qml-debug -no-accessibility -qt-freetype \
	-no-harfbuzz -no-iconv -no-gif -no-libjpeg -qt-libpng -no-nis -no-sql-mysql \
	-no-sql-sqlite -nomake tools

#	-opensource -confirm-license -release -static -no-accessibility -no-pulseaudio \
#	-no-alsa -no-gtkstyle -no-fontconfig -no-xcb-xlib -no-xcb \
#	-no-nis -no-cups -verbose -qt-zlib -qt-libpng -no-gif -no-libjpeg \
#	-no-openssl -no-iconv -no-dbus -no-largefile -no-xinerama -no-xrender -no-freetype \
#	-nomake examples -nomake tests -no-glib -no-eglfs -no-directfb -no-kms -no-libinput \
#	-no-opengl -no-glib -no-xinput2 -qpa linuxfb -linuxfb -debug

QT_FRAMEBUFFER_LIB=qtbase/plugins/platforms/libqlinuxfb.a

# linbo_gui
LINBO_SRC=$(CURDIR)/$(GUI_NAME)/*
GUI_NAME=linbo_gui
GUI_BUILD32=$(BUILDDIR)/build-$(GUI_NAME)-fb32
GUI_BUILD64=$(BUILDDIR)/build-$(GUI_NAME)-fb64

# targets

$(QT_ARCHIVE):
	wget --directory-prefix=$(CACHEDIR) $(QT_URL)/$(QT_ARCHIVE_NAME)
	grep $(QT_ARCHIVE) $(DEBIANDIR)/md5sums.src | md5sum -c

$(QT_SRC)/configure: $(QT_ARCHIVE)
	mkdir -p $(QT_SRC);
	echo "[1mUnpacking $(QT_ARCHIVE_NAME)...[0m" ;
	7z x $(QT_ARCHIVE) -o$(CURDIR)
	touch $(QT_SRC)/configure

config-qt32: $(QT_BUILD32)/Makefile

$(QT_BUILD32)/Makefile: $(QT_SRC)/configure
	mkdir -p $(QT_BUILD32);
	cd $(QT_BUILD32) && echo -e "yes\n" | PATH=$(TOOLCHAIN):$(PATH) $(QT_SRC)/configure -prefix $(shell pwd) $(QT_OPTS) $(QT_BUILD32OPTS)

config-qt64: $(QT_BUILD64)/Makefile

$(QT_BUILD64)/Makefile: $(QT_SRC)/configure
	mkdir -p $(QT_BUILD64);
	cd $(QT_BUILD64) && echo -e "yes\n" | $(QT_SRC)/configure -prefix /usr $(QT_OPTS) $(QT_BUILD64OPTS)

configure-gui:
	mkdir -p $(GUI_BUILD32);
	mkdir -p $(GUI_BUILD64);

configure: config-qt32 config-qt64 configure-gui

configure-stamp: configure
	touch configure-stamp

build-qt32: $(QT_BUILD32)/$(QT_FRAMEBUFFER_LIB)

$(QT_BUILD32)/$(QT_FRAMEBUFFER_LIB): $(QT_BUILD32)/Makefile
	cd $(QT_BUILD32) && PATH=$(TOOLCHAIN):$(PATH) make -j 2;

build-qt64: $(QT_BUILD64)/$(QT_FRAMEBUFFER_LIB)

$(QT_BUILD64)/$(QT_FRAMEBUFFER_LIB): $(QT_BUILD64)/Makefile
	cd $(QT_BUILD64) && make -j 2;

$(GUI_BUILD32)/linbo_gui: $(LINBO_SRC) build-qt32
	echo "[1mBuilding 32bit linbo_gui...[0m";
	cp $(CURDIR)/var/icons/linbo_wallpaper_800x600.png $(GUI_BUILD32)/icons/linbo_wallpaper.png;
	( 
	CFLAGS=-m32
	QTDIR=$(QT_BUILD32)
	QTLIB=$QTDIR/lib/
	QTBIN=$QTDIR/bin/ 
	cd $(GUI_BUILD32) && PATH=$(TOOLCHAIN):$(PATH) "$QTBIN"/qmake -makefile -spec "$QTDIR"/mkspecs/default $(GUI_SRC)/linbo_gui.pro
	make clean
	make
	strip linbo_gui
	)

$(GUI_BUILD64)/linbo_gui: $(LINBO_SRC) build-qt64
	@echo "[1mBuilding 64bit linbo_gui...[0m";
	install -D $(CURDIR)/var/icons/linbo_wallpaper_800x600.png $(GUI_BUILD64)/icons/linbo_wallpaper.png;
	QTDIR=$(QT_BUILD64)/qtbase \
	QTLIB=$(QT_BUILD64)/qtbase/lib \
	QTBIN=$(QT_BUILD64)/qtbase/bin \
	cd $(GUI_BUILD64) && PATH=/usr/bin:/bin $(QT_BUILD64)/qtbase/bin/qmake \
	-makefile -spec $(QT_SRC)/qtbase/mkspecs/linux-g++-64 $(CURDIR)/$(GUI_NAME)/linbo_gui.pro
	cd $(GUI_BUILD64) && make clean && make && strip linbo_gui

build-gui32: $(GUI_BUILD32)/linbo_gui

build-gui64:  $(GUI_BUILD64)/linbo_gui

build-gui: build-gui32 build-gui64

build: build-stamp

build-stamp: configure-stamp build-gui
	touch build-stamp

distclean: clean

	rm -rf $(QT_ARCHIVE) $(QT_SRC) $(QT_BUILD32) $(QT_BUILD64) $(GUI_BUILD32) $(GUI_BUILD64)

clean: 
	rm -f build-stamp configure-stamp

install: build

.PHONY: build clean install configure
