linuxmuster-linbo
=================

Buildroot
---------

Verwendet wird gerade `buildroot-2016.05`.
Der Buildroot-Subtree sollte nicht veraendert werden, alle Aenderungen gehen in den Ordner `buildroot-external`. Bei ein paar Sachen liess sich das aber nicht vermeiden, die Veraenderungen sind in `buildroot-2016.05.patch` aufgefuehrt.

### Update

Buildroot bringt alle drei Monate eine neuer Version raus. Der Subtree laesst sich so updaten (Branch, an dem gearbeitet wird heisst `buildroot`):

    $ git checkout -b buildroot-2016.05  
    $ git subtree pull --prefix buildroot git://git.buildroot.net/buildroot 2016.05  
    $ git checkout buildroot  
    $ git merge --squash buildroot-2016.05  

### Konfiguration anpassen

Buildroot verwendet menuconfig. Zur Konfiguration erst in den `buildroot`-Ordner wechseln.  
Wenn der Paketbau noch nicht angefangen wurde muss erst die defconfig geladen werden:

    $ make BR2_EXTERNAL=../buildroot-external/ O=../build/build-i386/ linbo-i386_defconfig

Bzw.`x86_64` statt `i386` fuer 64 Bit.

    $ make O=../build/build-i386 menuconfig

Um die defconfig zu aktualisieren:

    $ make O=../build/build-i386/ savedefconfig

Um den Kernel zu konfigurieren:

    $ make O=../build/build-i386/ linux-menuconfig

Um die defconfig vom Kernel zu aktualisieren:

    $ make O=../build/build-i386/ linux-savedefconfig
    $ make O=../build/build-i386/ linux-update-defconfig

Paket bauen
-----------

Getestet auf Ubuntu 16.04 amd64

    $ dpkg-buildpackage -us -uc
oder

    $ debuild
