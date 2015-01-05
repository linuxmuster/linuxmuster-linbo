Windows(tm) Registry-Patches fuer LINBO
---------------------------------------

* F�r jedes Windows-Image muss unter /var/linbo eine Patch-Datei nach diesen
  Mustern bereitgestellt werden:
  <ImageName>.cloop.reg
  <ImageName>.rsync.reg

* In den Image-Patch-Dateien muss ggf. der Domaenenname angepasst werden
  (winxp.reg, win7.image.reg).

* Die Patch-Dateien k�nnen mit eigenen Registry-Eintr�gen erg�nzt werden.

* Besonderheiten bei Windows 7:
  Es gibt drei Vorlagen f�r Registry-Patches:
  o win7.image.reg: Registry-Patch f�r Hostname und Domaene, der dem Image
    beigelegt wird (s.o.).
  o win7.global.reg: Notwendige und optionale Registry-Eintr�ge (siehe
    Kommentare in der Datei), die jeweils vor Domaenenbeitritt und Image-
    erstellung eingespielt werden m�ssen (Doppelklick auf die Datei).
  o win7.storage.reg: Wird zum Zwecke der Imagevereinheitlichung bei unter-
    schiedlicher Hardware vor der Erstellung des Images eingespielt. Der Patch
    aktiviert beim Betriebssystemstart das Laden diverser Kontroller-Treiber.

---
$Id: README-reg.txt 985 2011-03-06 12:09:53Z tschmitt $

