#!/usr/bin/make -f
#
# thomas@linuxmuster.net
# 08.03.2015
# GPL v3
#

include common.mk

# qt
QT_ARCHIVE=$(shell grep qt- debian/md5sums.src | awk '{ print $$2 }')
QT_VERS=$(shell echo $(QT_ARCHIVE) | sed -e 's/qt-everywhere-opensource-src-//' | sed -e 's/.7z//')
QT_URL=http://download.qt-project.org/official_releases/qt/5.5/$(QT_VERS)/single
QT_SRC=$(shell echo $(QT_ARCHIVE) | sed -e 's/.7z//')
QT_BUILD32=build-qt32
QT_BUILD32OPTS=-xplatform linux-g++-32 -device-option CROSS_COMPILE=i386-linux-gnu- -embedded x86
QT_BUILD64=build-qt64
QT_BUILD64OPTS=
QT_OPTS=-opensource -confirm-license -release -static -no-accessibility -no-pulseaudio -no-alsa -no-gtkstyle \
	-no-nis -no-cups -verbose -qt-zlib -qt-libpng -no-gif -no-libjpeg -qt-xcb \
	-no-openssl -no-iconv -no-dbus -no-largefile -no-xinerama -no-xrender -no-freetype -no-opengl -no-glib \
	-nomake examples -nomake tests -no-glib -no-eglfs -no-directfb -no-kms -qpa xcb -no-libinput \
	-no-opengl

# linbo_gui
GUI_SRC=linbo_gui
GUI_BUILD32=build-$(GUI_SRC)-fb32
GUI_BUILD64=build-$(GUI_SRC)-fb64

# targets

configure-toolchain32:
	# setup 32bit build tool chain
	mkdir -p $(TOOLCHAIN)
	#ln -sf /usr/bin/ar $(TOOLCHAIN)/i386-linux-gnu-ar
	#ln -sf /usr/bin/strip $(TOOLCHAIN)/i386-linux-gnu-strip
	cp -f /usr/bin/ar $(TOOLCHAIN)/i386-linux-gnu-ar
	cp -f /usr/bin/strip $(TOOLCHAIN)/i386-linux-gnu-strip
	#ln -sf i386-linux-gnu-gcc $(TOOLCHAIN)/gcc
	#ln -sf i386-linux-gnu-g++ $(TOOLCHAIN)/g++
	#ln -sf i386-linux-gnu-c++ $(TOOLCHAIN)/c++

cache/$(QT_ARCHIVE):
	cd cache && wget $(QT_URL)/$(QT_ARCHIVE);
	cd cache && grep $(QT_ARCHIVE) ../debian/md5sums.src | md5sum -c;

src-qt: cache/$(QT_ARCHIVE)
	mkdir -p $(QT_SRC);
	echo "[1mUnpacking $(QT_ARCHIVE)...[0m" ;
	7z x cache/$(QT_ARCHIVE)

configure-qt32: src-qt configure-toolchain32
	mkdir -p $(QT_BUILD32);
	cd $(QT_BUILD32) && echo -e "yes\n" | QTDIR=$(QT_BUILD32) PATH=$(TOOLCHAIN):$(PATH) ../$(QT_SRC)/configure -prefix $(QTDIR) $(QT_OPTS) $(QT_BUILD32OPTS)

configure-qt64: #src-qt
	mkdir -p $(QT_BUILD64);
	cd $(QT_BUILD64) && echo -e "yes\n" | ../$(QT_SRC)/configure -prefix $(shell pwd) $(QT_OPTS) $(QT_BUILD64OPTS)

configure-qt: configure-qt32 configure-qt64

configure-gui32:
	mkdir -p $(GUI_BUILD32);

configure-gui64:
	mkdir -p $(GUI_BUILD64);

configure-gui: configure-gui32 configure-gui64

configure: configure-stamp configure-qt configure-gui configure-toolchain32
configure-stamp:
	touch configure-stamp

build-qt32: configure-qt32
	cd $(QT_BUILD32) && PATH=$(TOOLCHAIN):$(PATH) make -j 2;

build-qt64: configure-qt64
	cd $(QT_BUILD64) && make -j 2;

build-qt: build-qt32 build-qt64

build-gui32: build-qt32
	echo "[1mBuilding 32bit linbo_gui...[0m";
	cp var/icons/linbo_wallpaper_800x600.png linbo_gui32/icons/linbo_wallpaper.png;
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

build-gui64: build-qt64
	echo "[1mBuilding 64bit linbo_gui...[0m";
	cp var/icons/linbo_wallpaper_800x600.png linbo_gui32/icons/linbo_wallpaper.png;
	( 
	QTDIR=$(QT_BUILD64)
	QTLIB=$QTDIR/lib/
	QTBIN=$QTDIR/bin/ 
	cd $(GUI_BUILD64)
	"$QTBIN"/qmake -makefile -spec "$QTDIR"/mkspecs/default $(GUI_SRC)/linbo_gui.pro
	make clean
	make
	strip linbo_gui
	)

build-gui: build-gui32 build-gui64

build: build-stamp
build-stamp: configure-stamp build-gui
	touch build-stamp

distclean: clean

	rm -rf $(QT_SRC) $(QT_BUILD32) $(QT_BUILD64) $(GUI_BUILD32) $(GUI_BUILD64)

clean: 
	rm -f build-stamp configure-stamp $(TOOLCHAIN)/i386-linux-gnu-ar $(TOOLCHAIN)/i386-linux-gnu-strip

install: build

.PHONY: build clean install configure
