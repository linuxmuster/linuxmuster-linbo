# linuxmuster-linbo

## Buildroot

Verwendet wird gerade `buildroot-2016.02`.
Der Buildroot-Subtree sollte nicht veraendert werden, alle Aenderungen gehen in den Ordner `buildroot-external`. Bei ein paar Sachen liess sich das aber nicht vermeiden, die Veraenderungen sind in `buildroot-2016.02.patch` aufgefuehrt.

## Paket bauen

Getestet auf Ubuntu 16.04 amd64

```
$ ./buildpackage.sh
```

Fehlende Abhaengigkeiten installieren, dann nochmal

```
$ ./buildpackage.sh
```
