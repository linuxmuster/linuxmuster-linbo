Windows(tm) Registry-Patches fuer LINBO
---------------------------------------

* Für jedes Windows-Image muss unter /var/linbo eine Patch-Datei nach diesen
  Mustern bereitgestellt werden:
  <ImageName>.cloop.reg
  <ImageName>.rsync.reg

* In den Image-Patch-Dateien muss ggf. der Domaenenname angepasst werden
  (winxp.reg, win7.image.reg).

* Die Patch-Dateien können mit eigenen Registry-Einträgen ergänzt werden.

* Besonderheiten bei Windows 7:
  Es gibt drei Vorlagen für Registry-Patches:
  o win7.image.reg: Registry-Patch für Hostname und Domaene, der dem Image
    beigelegt wird (s.o.).
  o win7.global.reg: Notwendige und optionale Registry-Einträge (siehe
    Kommentare in der Datei), die jeweils vor Domaenenbeitritt und Image-
    erstellung eingespielt werden müssen (Doppelklick auf die Datei).
  o win7.storage.reg: Wird zum Zwecke der Imagevereinheitlichung bei unter-
    schiedlicher Hardware vor der Erstellung des Images eingespielt. Der Patch
    aktiviert beim Betriebssystemstart das Laden diverser Kontroller-Treiber.

---
$Id: README-reg.txt 985 2011-03-06 12:09:53Z tschmitt $

