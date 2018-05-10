# Makefile
# Wir haben einen Rechner, der per PXE werder GRUB-2.02~rc2 noch ein kompiliertes GRUB-2.02~rc2
# noch den GRUB aus dem Ubuntu-Paket bootet, weshalb hier nochmal ein funktionierender GRUB gebaut wird.
BUILDROOT=$(CURDIR)/buildroot
BUILDDIR=$(CURDIR)/build
BUILD32=$(BUILDDIR)/build-i386
BUILD64=$(BUILDDIR)/build-x86_64
BUILD64DEBUG=$(BUILDDIR)/build-x86_64-debug
LINBO_VERSION=$(shell cat rpm/oss-linbo.spec | grep '^Version:' | awk '{ print $$2 }')
LINBO_RELEASE=$(shell cat rpm/oss-linbo.spec | grep '^Release:' | awk '{ print $$2 }')

ifeq ("$(BR2_DL_DIR)","")
	BR2_DL_DIR=$(BUILDROOT)/dl
endif

clean:
	rm -rf build/

.PHONY: build-linbo build

config-debug:
	echo "LINBO $(LINBO_VERSION)-$(LINBO_RELEASE)" >linbofs/etc/linbo-version
	cd $(BUILDROOT)-external/configs; cp linbo-x86_64_defconfig.debug linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD64DEBUG) BR2_EXTERNAL=$(BUILDROOT)-external linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD64DEBUG) menuconfig
	cd $(BUILDROOT); make O=$(BUILD64DEBUG) savedefconfig
	cd $(BUILDROOT)-external/configs; cp linbo-x86_64_defconfig linbo-x86_64_defconfig.debug

config-nodebug:
	echo "LINBO $(LINBO_VERSION)-$(LINBO_RELEASE)" >linbofs/etc/linbo-version
	cd $(BUILDROOT)-external/configs; cp linbo-x86_64_defconfig.nodebug linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD64) BR2_EXTERNAL=$(BUILDROOT)-external linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD64) menuconfig
	cd $(BUILDROOT); make O=$(BUILD64) savedefconfig
	cd $(BUILDROOT)-external/configs; cp linbo-x86_64_defconfig linbo-x86_64_defconfig.nodebug

build-linbo:
	echo "LINBO $(LINBO_VERSION)-$(LINBO_RELEASE)" >linbofs/etc/linbo-version
	cd $(BUILDROOT); make O=$(BUILD32) BR2_EXTERNAL=$(BUILDROOT)-external linbo-i386_defconfig
	cd $(BUILDROOT)-external/configs; cp linbo-x86_64_defconfig.nodebug linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD64) BR2_EXTERNAL=$(BUILDROOT)-external linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD32)
	cd $(BUILDROOT); make O=$(BUILD64)

build-debug:
	echo "LINBO $(LINBO_VERSION)-$(LINBO_RELEASE)" >linbofs/etc/linbo-version
	cd $(BUILDROOT)-external/configs; cp linbo-x86_64_defconfig.debug linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD64DEBUG) BR2_EXTERNAL=$(BUILDROOT)-external linbo-x86_64_defconfig
	cd $(BUILDROOT); make O=$(BUILD64DEBUG)

build: build-linbo
