# linuxmuster-linbo

## Buildroot

Verwendet wird gerade `buildroot-2016.05`.
Der Buildroot-Subtree sollte nicht veraendert werden, alle Aenderungen gehen in den Ordner `buildroot-external`. Bei ein paar Sachen liess sich das aber nicht vermeiden, die Veraenderungen sind in `buildroot-2016.05.patch` aufgefuehrt.

### Update

Buildroot bringt alle drei Monate eine neuer Version raus. Der Subtree laesst sich so updaten (Branch, an dem gearbeitet wird heisst `buildroot`):

```
$ git checkout -b buildroot-2016.05
$ git subtree pull --prefix buildroot git://git.buildroot.net/buildroot 2016.05
$ git checkout buildroot
$ git merge --squash buildroot-2016.05
```

## Paket bauen

Getestet auf Ubuntu 16.04 amd64

```
$ ./buildpackage.sh
```

Fehlende Abhaengigkeiten installieren, dann nochmal

```
$ ./buildpackage.sh
```
