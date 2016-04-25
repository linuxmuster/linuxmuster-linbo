#!/usr/bin/make -f
#
# make linbo gui
#
# Frank Schütte
# 2016

CURDIR=$(shell pwd)/..

include ../common.mk

ifdef $(DEBUG)
    QT_DEBUG=-debug
else
    QT_DEBUG=
endif

# qt
QT_ARCHIVE=$(CACHEDIR)/$(shell grep qt- $(DEBIANDIR)/md5sums.src | awk '{ print $$2 }')
QT_VERS=$(shell echo $(notdir $(QT_ARCHIVE)) | sed -e 's/qt-everywhere-opensource-src-//' -e 's/.7z//')
QT_MAJOR=$(shell echo $(QT_VERS) | awk -F\. '{ print $$1"."$$2 }')
QT_URL=http://download.qt-project.org/official_releases/qt/$(QT_MAJOR)/$(QT_VERS)/single
QT_SRC=$(CURDIR)/$(shell echo $(notdir $(QT_ARCHIVE)) | sed -e 's/.7z//')
QT_BUILD32=$(BUILDDIR)/build-qt32
QT_BUILD32OPTS=-xplatform linux-g++-32 -device-option CROSS_COMPILE=i386-linux-gnu- -sysroot $(SYSROOT)
QT_BUILD64=$(BUILDDIR)/build-qt64
QT_BUILD64OPTS=-sysroot $(SYSROOT64) 
QT_OPTS=-debug -qpa linuxfb -linuxfb -static -opensource -confirm-license -nomake examples \
	-no-dbus -no-largefile -no-qml-debug -no-accessibility -qt-freetype \
	-no-harfbuzz -no-iconv -no-gif -no-libjpeg -qt-libpng -no-nis -no-sql-mysql \
	-no-sql-sqlite -nomake tools -no-libinput -verbose

QT_FRAMEBUFFER_LIB=qtbase/plugins/platforms/libqlinuxfb.a
QT_FONT=usr/lib/fonts/DejaVuSans.ttf

# linbo_gui
LINBO_SRC=$(CURDIR)/$(GUI_NAME)/*.h $(CURDIR)/$(GUI_NAME)/*.cpp $(CURDIR)/$(GUI_NAME)/*.ui
GUI_NAME=linbo_gui
GUISRCDIR=$(CURDIR)/$(GUI_NAME)
GUI_BUILD32=$(BUILDDIR)/build-gui32
GUI_BUILD64=$(BUILDDIR)/build-gui64

# targets
all: build

$(QT_ARCHIVE):
	wget --directory-prefix=$(CACHEDIR) $(QT_URL)/$(notdir $(QT_ARCHIVE))
	cd $(CACHEDIR); grep $(notdir $(QT_ARCHIVE)) $(DEBIANDIR)/md5sums.src | md5sum -c

$(QT_SRC)/configure: $(QT_ARCHIVE)
	mkdir -p $(QT_SRC);
	echo "[1mUnpacking $(notdir $(QT_ARCHIVE))...[0m" ;
	7z x $(QT_ARCHIVE) -o$(CURDIR)
	touch $(QT_SRC)/configure

config-qt32: $(QT_BUILD32)/Makefile

$(QT_BUILD32)/Makefile: $(QT_SRC)/configure
	mkdir -p $(QT_BUILD32);
	( cd $(QT_BUILD32) ; PKG_CONFIG_LIBDIR=$(SYSROOT)/usr/lib/pkgconfig \
	PKG_CONFIG_PATH="" ACLOCAL_FLAGS="-I $(SYSROOT)/usr/share/aclocal" \
	CPPFLAGS=-I$(SYSROOT)/usr/include LDFLAGS=-L$(SYSROOT)/usr/lib \
	echo -e "yes\n" | $(QT_SRC)/configure -prefix /usr $(QT_OPTS) $(QT_BUILD32OPTS) )

config-qt64: $(QT_BUILD64)/Makefile

$(QT_BUILD64)/Makefile: $(QT_SRC)/configure
	mkdir -p $(QT_BUILD64);
	( cd $(QT_BUILD64) ; PKG_CONFIG_LIBDIR=$(SYSROOT64)/usr/lib/pkgconfig \
	PKG_CONFIG_PATH="" ACLOCAL_FLAGS="-I $(SYSROOT64)/usr/share/aclocal" \
	CPPFLAGS=-I$(SYSROOT64)/usr/include LDFLAGS=-L$(SYSROOT64)/usr/lib \
	echo -e "yes\n" | $(QT_SRC)/configure -prefix /usr $(QT_OPTS) $(QT_BUILD64OPTS) )

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

$(GUI_BUILD32)/linbo_gui: $(QT_BUILD32)/$(QT_FRAMEBUFFER_LIB) $(LINBO_SRC)
	@echo "[1mBuilding 32bit linbo_gui...[0m";
	install -D $(CURDIR)/var/icons/linbo_wallpaper_800x600.png $(GUI_BUILD32)/icons/linbo_wallpaper.png;
	QTDIR=$(QT_BUILD32)/qtbase \
	QTLIB=$(QT_BUILD32)/qtbase/lib \
	QTBIN=$(QT_BUILD32)/qtbase/bin \
	cd $(GUI_BUILD32) && PATH=/usr/bin:/bin $(QT_BUILD32)/qtbase/bin/qmake \
	-makefile -spec $(QT_SRC)/qtbase/mkspecs/linux-g++-32 $(CURDIR)/$(GUI_NAME)/linbo_gui.pro
	cd $(GUI_BUILD32) && make clean && make && strip linbo_gui

$(GUI_BUILD64)/linbo_gui: $(QT_BUILD64)/$(QT_FRAMEBUFFER_LIB) $(LINBO_SRC)
	@echo "[1mBuilding 64bit linbo_gui...[0m";
	install -D $(CURDIR)/var/icons/linbo_wallpaper_800x600.png $(GUI_BUILD64)/icons/linbo_wallpaper.png;
	QTDIR=$(QT_BUILD64)/qtbase \
	QTLIB=$(QT_BUILD64)/qtbase/lib \
	QTBIN=$(QT_BUILD64)/qtbase/bin \
	cd $(GUI_BUILD64) && PATH=/usr/bin:/bin $(QT_BUILD64)/qtbase/bin/qmake \
	-makefile -spec $(QT_SRC)/qtbase/mkspecs/linux-g++-64 $(CURDIR)/$(GUI_NAME)/linbo_gui.pro
	cd $(GUI_BUILD64); make clean && make && strip linbo_gui

build-gui32: $(GUI_BUILD32)/linbo_gui

build-gui64:  $(GUI_BUILD64)/linbo_gui

build-gui: build-gui32 build-gui64

build: build-stamp

build-stamp: configure-stamp build-gui
	touch build-stamp

distclean: clean

	rm -rf $(QT_ARCHIVE) $(QT_SRC)

clean: 
	rm -f build-stamp configure-stamp
	rm -rf $(QT_BUILD32) $(QT_BUILD64) $(GUI_BUILD32) $(GUI_BUILD64)

$(SYSROOT)/usr/bin/linbo_gui: $(GUI_BUILD32)/linbo_gui
	install -D $(GUI_BUILD32)/linbo_gui $(SYSROOT)/usr/bin/linbo_gui

$(SYSROOT64)/usr/bin/linbo_gui: $(GUI_BUILD64)/linbo_gui
	install -D $(GUI_BUILD64)/linbo_gui $(SYSROOT64)/usr/bin/linbo_gui

install: $(addsuffix /usr/bin/linbo_gui, $(SYSROOT) $(SYSROOT64)) $(addsuffix /$(QT_FONT), $(SYSROOT) $(SYSROOT64))

install-qt: $(addsuffix /$(QT_FONT), $(SYSROOT) $(SYSROOT64))

$(addsuffix /$(QT_FONT), $(SYSROOT) $(SYSROOT64)): $(addsuffix /$(QT_FRAMEBUFFER_LIB), $(QT_BUILD32) $(QT_BUILD64))
	cd $(QT_BUILD32); make install
	cd $(QT_BUILD64); make install
	touch $(addsuffix /$(QT_FONT), $(SYSROOT) $(SYSROOT64))

$(GUI_BUILD32)/start.conf $(GUI_BUILD64)/start.conf: $(GUISRCDIR)/test/start.conf
	install -D $(GUISRCDIR)/test/start.conf $(GUI_BUILD32)/start.conf
	install -D $(GUISRCDIR)/test/start.conf $(GUI_BUILD64)/start.conf

$(GUI_BUILD32)/linbo_cmd $(GUI_BUILD64)/linbo_cmd: $(GUISRCDIR)/test/fake_cmd.sh
	install -D $(GUISRCDIR)/test/fake_cmd.sh $(GUI_BUILD32)/linbo_cmd
	install -D $(GUISRCDIR)/test/fake_cmd_create.sh $(GUI_BUILD32)/fake_cmd_create.sh
	install -D $(GUISRCDIR)/test/fake_cmd_functions.sh $(GUI_BUILD32)/fake_cmd_functions.sh
	install -D $(GUISRCDIR)/test/fake_cmd.sh $(GUI_BUILD64)/linbo_cmd
	install -D $(GUISRCDIR)/test/fake_cmd_create.sh $(GUI_BUILD64)/fake_cmd_create.sh
	install -D $(GUISRCDIR)/test/fake_cmd_functions.sh $(GUI_BUILD64)/fake_cmd_functions.sh

install-test: $(GUI_BUILD32)/linbo_cmd $(GUI_BUILD32)/start.conf $(GUI_BUILD64)/linbo_cmd $(GUI_BUILD64)/start.conf

.PHONY: all
.PHONY: build build-gui build-gui32 build-gui64 build-qt32 build-qt64
.PHONY: clean distclean
.PHONY: configure configure-gui config-qt32 config-qt64
.PHONY: install install-test install-qt
